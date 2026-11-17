# Publishing a privacy policy version

The app reads the privacy policy from Firestore and never writes it. New
versions are published from your computer with `publish_policy.mjs`, which
uses the Firebase Admin SDK (already in `package.json`).

```
policies/privacy                    currentVersion, minimumAcceptedVersion,
                                    requiresReacceptance, effectiveFrom
policies/privacy/versions/{n}       version, effectiveFrom, textEs, textEn,
                                    policyCheckbox, healthDataCheckbox, changeSummary
```

Every version is a JSON file in `assets/policies/` (for example
`privacy_v3.json`). The same file the script publishes is the one you can
bundle in the app as the offline copy.

## Rules the script enforces

- A published version is never changed. `--apply` uses Firestore `create()`,
  which fails if the version exists; a file whose text differs from the
  published one is refused. New text means a new version number.
- `policies/privacy` changes only with `--activate`, never by accident.
- Both languages, every section, both checkbox labels and the change summary
  must be filled in. Leftover placeholders such as `[PUBLICATION_DATE]` block
  publication.
- Every write shows what will change and asks you to type the version number.
- The first version published must be `--mandatory`, and a version can only
  be activated if it is newer than the current one.

## One-time setup

1. Check Node is installed: `node --version` (18 or newer).
2. In the repo folder: `npm install`.
3. The admin key goes in `firebase/serviceAccountKey.json`, the same one the
   other upload scripts use; git ignores that folder. If it is missing:
   Firebase console > Project settings > Service accounts > Generate new
   private key. Never commit or share it.

## Publishing a new version (example: version 3)

1. Copy the last version: `assets/policies/privacy_v2.json` to
   `assets/policies/privacy_v3.json`.
2. Edit the copy: `version` to 3, `effectiveFrom` (date with time zone, for
   example `2027-01-10T00:00:00-05:00`), the Spanish text (the legal
   reference), the English translation, the checkbox labels if they change,
   and `changeSummary` in both languages.
3. Dry run, which writes nothing:
   `node tool/publish_policy/publish_policy.mjs assets/policies/privacy_v3.json`
   It checks the file, shows the Firebase project, the current
   `policies/privacy` and whether version 3 exists.
4. Create the version (users do not see it yet):
   `node tool/publish_policy/publish_policy.mjs assets/policies/privacy_v3.json --apply`
5. Check it in the Firebase console: Firestore > policies > privacy >
   versions > 3.
6. Make it current, choosing one:
   - `--activate --mandatory`: everyone must accept it before using the app
     (substantial change: controller, purposes, data processed).
   - `--activate --minor`: users only see a notice on Home.
7. Open the app and check the acceptance screen or the notice.
8. Commit the new JSON file, so the repo records what was published.

Updating the offline copy bundled in the app (`BundledPrivacyPolicy.assetPath`)
is optional and only reaches users with a new release.

## First launch of version 2, in this order

1. Fill in the publication date in `assets/policies/privacy_v2.json` and
   publish it with steps 3 to 6 above, using `--mandatory`.
2. Deploy `firestore.rules` (`firebase deploy --only firestore:rules`) after
   comparing it with the rules in the console. Until `policies/privacy`
   exists, these rules refuse to save any acceptance.
3. Release the app.

## Checking the script

- Validation tests: `node --test tool/publish_policy/validate.test.mjs`
- Rehearsal without touching real data: start the Firestore emulator
  (`npx firebase-tools emulators:start --only firestore --project demo-muevete`),
  then run the same commands with `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`
  set. The script then needs no key and says it is using the emulator.
