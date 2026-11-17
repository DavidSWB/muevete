#!/usr/bin/env node
// Publishes a privacy policy version to Firestore. See README.md.
//
//   node tool/publish_policy/publish_policy.mjs <file.json>             dry run: checks, writes nothing
//   ... <file.json> --apply                                              creates policies/privacy/versions/{n}
//   ... <file.json> --activate --mandatory | --minor                     makes {n} the current version
//
// Options: --key <path> (default: firebase/serviceAccountKey.json, or
// GOOGLE_APPLICATION_CREDENTIALS). Every write asks you to type the version
// number first. A published version is never overwritten. With
// FIRESTORE_EMULATOR_HOST set, it rehearses against the local emulator.

import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { createInterface } from 'node:readline/promises';
import { nextMetadata, validatePolicyVersion } from './validate.mjs';

const USAGE =
  'Usage: node tool/publish_policy/publish_policy.mjs <file.json> [--apply] [--activate --mandatory|--minor] [--key <path>]';

function parseArgs(argv) {
  const options = { apply: false, activate: false, mode: null, key: null, file: null };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--apply') options.apply = true;
    else if (arg === '--activate') options.activate = true;
    else if (arg === '--mandatory' || arg === '--minor') {
      if (options.mode) fail('Use only one of --mandatory and --minor.');
      options.mode = arg.slice(2);
    } else if (arg === '--key') options.key = argv[++i];
    else if (arg.startsWith('--')) fail(`Unknown option ${arg}.\n${USAGE}`);
    else if (options.file) fail(`Only one file at a time.\n${USAGE}`);
    else options.file = arg;
  }
  if (!options.file) fail(USAGE);
  if (options.mode && !options.activate) fail('--mandatory and --minor only go with --activate.');
  if (options.activate && !options.mode) {
    fail('--activate needs --mandatory (users must accept again) or --minor (users only see a notice).');
  }
  return options;
}

function fail(message) {
  console.error(`\n✗ ${message}\n`);
  process.exit(1);
}

/** JSON with sorted keys, so two documents can be compared. */
function canonical(value) {
  if (Array.isArray(value)) return `[${value.map(canonical).join(',')}]`;
  if (value && typeof value === 'object') {
    return `{${Object.keys(value).sort().map((k) => `${JSON.stringify(k)}:${canonical(value[k])}`).join(',')}}`;
  }
  return JSON.stringify(value);
}

function sameContent(fileDoc, storedDoc) {
  const stored = { ...storedDoc };
  if (stored.effectiveFrom && typeof stored.effectiveFrom.toDate === 'function') {
    stored.effectiveFrom = stored.effectiveFrom.toDate().getTime();
  }
  const local = { ...fileDoc, effectiveFrom: Date.parse(fileDoc.effectiveFrom) };
  return canonical(local) === canonical(stored);
}

function describeMetadata(data) {
  if (!data) return '  (does not exist yet)';
  const date = data.effectiveFrom?.toDate ? data.effectiveFrom.toDate().toISOString() : data.effectiveFrom;
  return [
    `  currentVersion:         ${data.currentVersion}`,
    `  minimumAcceptedVersion: ${data.minimumAcceptedVersion}`,
    `  requiresReacceptance:   ${data.requiresReacceptance}`,
    `  effectiveFrom:          ${date}`,
  ].join('\n');
}

// One reader for the whole run, so each confirmation gets its own line.
let input;

async function confirm(version, action) {
  input ??= createInterface({ input: process.stdin })[Symbol.asyncIterator]();
  process.stdout.write(`\nType ${version} to ${action}, or anything else to stop: `);
  const { value, done } = await input.next();
  if (done || value.trim() !== String(version)) fail('Stopped. Nothing was written.');
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const path = resolve(options.file);
  if (!existsSync(path)) fail(`File not found: ${path}`);

  let doc;
  try {
    doc = JSON.parse(readFileSync(path, 'utf8'));
  } catch (error) {
    fail(`${path} is not valid JSON: ${error.message}`);
  }

  console.log(`\nPrivacy policy file: ${path}`);
  const errors = validatePolicyVersion(doc);
  if (errors.length > 0) {
    fail(`The file cannot be published:\n  - ${errors.join('\n  - ')}`);
  }
  console.log(`✓ Valid: version ${doc.version}, effective from ${doc.effectiveFrom}`);
  console.log(`  ${doc.textEs.length} sections in Spanish and English`);
  console.log(`  Policy checkbox (es): ${doc.policyCheckbox.es}`);
  console.log(`  Health checkbox (es): ${doc.healthDataCheckbox.es}`);
  console.log(`  Change summary (es):  ${doc.changeSummary.es}`);

  const emulator = process.env.FIRESTORE_EMULATOR_HOST;
  const keyPath = resolve(options.key ?? process.env.GOOGLE_APPLICATION_CREDENTIALS ?? 'firebase/serviceAccountKey.json');
  if (!emulator && !existsSync(keyPath)) {
    if (options.apply || options.activate) fail(`Service account key not found: ${keyPath}`);
    console.log(`\nNo service account key at ${keyPath}: the file was checked, Firestore was not.`);
    return;
  }

  const { initializeApp, cert } = await import('firebase-admin/app');
  const { getFirestore, Timestamp } = await import('firebase-admin/firestore');
  let projectId;
  if (emulator) {
    // Rehearsal against the local emulator: no key, no real data.
    projectId = 'demo-muevete';
    initializeApp({ projectId });
    console.log(`\nLOCAL EMULATOR at ${emulator} (project ${projectId}); the real database is not touched.`);
  } else {
    const key = JSON.parse(readFileSync(keyPath, 'utf8'));
    projectId = key.project_id;
    initializeApp({ credential: cert(key) });
    console.log(`\nFirebase project: ${projectId}`);
  }
  const db = getFirestore();

  const parentRef = db.doc('policies/privacy');
  const versionRef = db.doc(`policies/privacy/versions/${doc.version}`);
  const [parentSnap, versionSnap] = await Promise.all([parentRef.get(), versionRef.get()]);
  const parent = parentSnap.exists ? parentSnap.data() : null;

  console.log('\npolicies/privacy now:');
  console.log(describeMetadata(parent));
  let published = versionSnap.exists;
  if (published) {
    const identical = sameContent(doc, versionSnap.data());
    console.log(`\nversions/${doc.version} already exists and is ${identical ? 'identical to this file' : 'DIFFERENT from this file'}.`);
    if (!identical && (options.apply || options.activate)) {
      fail(`Version ${doc.version} is already published with other content. Published versions never change: give the new text a new version number.`);
    }
  } else {
    console.log(`\nversions/${doc.version} does not exist yet.`);
  }

  if (!options.apply && !options.activate) {
    console.log('\nDry run: nothing was written.');
    console.log(published
      ? `Next: --activate --mandatory or --minor to make version ${doc.version} current.`
      : `Next: --apply to create versions/${doc.version}.`);
    return;
  }

  const stored = { ...doc, effectiveFrom: Timestamp.fromDate(new Date(doc.effectiveFrom)) };

  if (options.apply) {
    if (published) {
      console.log(`\nversions/${doc.version} is already published; nothing to create.`);
    } else {
      console.log(`\nAbout to CREATE policies/privacy/versions/${doc.version} in project ${projectId}.`);
      console.log('Users will not see it until you run --activate.');
      await confirm(doc.version, 'create it');
      await versionRef.create(stored); // Fails if it exists: never overwrites.
      published = true;
      console.log(`✓ Created policies/privacy/versions/${doc.version}.`);
    }
  }

  if (options.activate) {
    if (!published) fail(`versions/${doc.version} does not exist yet. Run with --apply first.`);
    const result = nextMetadata(parent, doc.version, stored.effectiveFrom, options.mode);
    if (result.error) fail(result.error);
    console.log(`\nAbout to UPDATE policies/privacy in project ${projectId}:`);
    console.log('  before:');
    console.log(describeMetadata(parent));
    console.log('  after:');
    console.log(describeMetadata(result.metadata));
    console.log(options.mode === 'mandatory'
      ? 'Every user will have to accept this version before using the app.'
      : 'Users will only see a notice on Home.');
    await confirm(doc.version, 'make it current');
    await db.runTransaction(async (transaction) => {
      const fresh = await transaction.get(parentRef);
      const before = fresh.exists ? fresh.data().currentVersion : undefined;
      if (before !== parent?.currentVersion) {
        throw new Error('policies/privacy changed while this script was running. Run it again.');
      }
      transaction.set(parentRef, result.metadata);
    });
    console.log(`✓ Version ${doc.version} is now the current privacy policy.`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => fail(error.message ?? String(error)));
