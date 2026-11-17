// Run with: node --test tool/publish_policy/
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { nextMetadata, validatePolicyVersion } from './validate.mjs';

const bundledPath = fileURLToPath(new URL('../../assets/policies/privacy_v2.json', import.meta.url));
const raw = readFileSync(bundledPath, 'utf8');

function readyV2() {
  // The bundled draft with the publication date filled in.
  return JSON.parse(raw.replaceAll('[PUBLICATION_DATE]', '20 de noviembre de 2026'));
}

test('the bundled version 2 passes once its date is filled in', () => {
  assert.deepEqual(validatePolicyVersion(readyV2()), []);
});

test('a leftover placeholder blocks publication', () => {
  const errors = validatePolicyVersion(JSON.parse(raw));
  if (!raw.includes('[PUBLICATION_DATE]')) return; // Date already filled in.
  assert.ok(errors.some((e) => e.includes('[PUBLICATION_DATE]')), errors.join('\n'));
});

test('incomplete content is refused', () => {
  const cases = [
    (d) => { d.version = 0; },
    (d) => { d.version = '2'; },
    (d) => { d.effectiveFrom = '2026-11-20'; },
    (d) => { delete d.textEn; },
    (d) => { d.textEs = []; },
    (d) => { d.textEn.pop(); },
    (d) => { d.textEs[0].title = ' '; },
    (d) => { d.textEs[0].blocks = []; },
    (d) => { d.textEs[0].blocks[0].type = 'heading'; },
    (d) => { d.textEn[1].blocks[0].text = ''; },
    (d) => { delete d.policyCheckbox.en; },
    (d) => { d.healthDataCheckbox.es = ''; },
    (d) => { delete d.changeSummary; },
    (d) => { d.currentVersion = 2; },
  ];
  for (const change of cases) {
    const doc = readyV2();
    change(doc);
    assert.notDeepEqual(validatePolicyVersion(doc), [], change.toString());
  }
});

test('first publication must be mandatory', () => {
  assert.ok(nextMetadata(null, 2, 'd', 'minor').error);
  assert.deepEqual(nextMetadata(null, 2, 'd', 'mandatory').metadata, {
    currentVersion: 2, minimumAcceptedVersion: 2, requiresReacceptance: true, effectiveFrom: 'd',
  });
});

test('a mandatory version raises the minimum, a minor one keeps it', () => {
  const current = { currentVersion: 3, minimumAcceptedVersion: 3, requiresReacceptance: true };
  assert.deepEqual(nextMetadata(current, 4, 'd', 'minor').metadata, {
    currentVersion: 4, minimumAcceptedVersion: 3, requiresReacceptance: false, effectiveFrom: 'd',
  });
  assert.deepEqual(nextMetadata(current, 4, 'd', 'mandatory').metadata, {
    currentVersion: 4, minimumAcceptedVersion: 4, requiresReacceptance: true, effectiveFrom: 'd',
  });
});

test('never activates an older or the same version', () => {
  const current = { currentVersion: 3, minimumAcceptedVersion: 2, requiresReacceptance: false };
  assert.ok(nextMetadata(current, 3, 'd', 'mandatory').error);
  assert.ok(nextMetadata(current, 2, 'd', 'minor').error);
  assert.ok(nextMetadata(current, 4, 'd', 'other').error);
});
