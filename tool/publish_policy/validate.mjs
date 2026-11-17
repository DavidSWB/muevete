// Checks a privacy policy version file before it is published. The rules
// match PrivacyPolicyCodec in the app (lib/features/privacy/data/), so
// anything that passes here can be shown by the app, plus checks that only
// matter when publishing (no leftover placeholders, a real date).

const LANGUAGES = ['es', 'en'];
const BLOCK_TYPES = ['paragraph', 'bullet'];
const LOCALIZED_FIELDS = ['policyCheckbox', 'healthDataCheckbox', 'changeSummary'];
const ALLOWED_FIELDS = ['version', 'effectiveFrom', 'textEs', 'textEn', ...LOCALIZED_FIELDS];

// Text such as [PUBLICATION_DATE] left in the draft.
const PLACEHOLDER = /\[[A-Z][A-Z0-9_]*\]/;

/** Returns the list of problems; an empty list means the file can be published. */
export function validatePolicyVersion(doc) {
  const errors = [];
  if (doc === null || typeof doc !== 'object' || Array.isArray(doc)) {
    return ['The file must contain one JSON object.'];
  }

  for (const key of Object.keys(doc)) {
    if (!ALLOWED_FIELDS.includes(key)) errors.push(`Unknown field "${key}".`);
  }

  if (!Number.isInteger(doc.version) || doc.version < 1) {
    errors.push('"version" must be a whole number of at least 1.');
  }

  if (typeof doc.effectiveFrom !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2})$/.test(doc.effectiveFrom)
      || Number.isNaN(Date.parse(doc.effectiveFrom))) {
    errors.push('"effectiveFrom" must be a date with time zone, for example 2026-11-20T00:00:00-05:00.');
  }

  for (const field of ['textEs', 'textEn']) {
    const sections = doc[field];
    if (!Array.isArray(sections) || sections.length === 0) {
      errors.push(`"${field}" must be a non-empty list of sections.`);
      continue;
    }
    sections.forEach((section, i) => {
      const where = `${field}[${i}]`;
      if (section === null || typeof section !== 'object') {
        errors.push(`${where} must be an object.`);
        return;
      }
      checkText(section.title, `${where}.title`, errors);
      if (!Array.isArray(section.blocks) || section.blocks.length === 0) {
        errors.push(`${where}.blocks must be a non-empty list.`);
        return;
      }
      section.blocks.forEach((block, j) => {
        const at = `${where}.blocks[${j}]`;
        if (block === null || typeof block !== 'object') {
          errors.push(`${at} must be an object.`);
          return;
        }
        if (!BLOCK_TYPES.includes(block.type)) {
          errors.push(`${at}.type must be "paragraph" or "bullet".`);
        }
        checkText(block.text, `${at}.text`, errors);
      });
    });
  }
  if (Array.isArray(doc.textEs) && Array.isArray(doc.textEn) && doc.textEs.length !== doc.textEn.length) {
    errors.push(`"textEs" has ${doc.textEs.length} sections but "textEn" has ${doc.textEn.length}.`);
  }

  for (const field of LOCALIZED_FIELDS) {
    const value = doc[field];
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
      errors.push(`"${field}" must be an object with "es" and "en".`);
      continue;
    }
    for (const language of LANGUAGES) checkText(value[language], `${field}.${language}`, errors);
  }

  return errors;
}

function checkText(value, where, errors) {
  if (typeof value !== 'string' || value.trim() === '') {
    errors.push(`${where} is required.`);
  } else if (PLACEHOLDER.test(value)) {
    errors.push(`${where} still contains the placeholder ${value.match(PLACEHOLDER)[0]}.`);
  }
}

/**
 * What `policies/privacy` becomes when [version] is activated, or an error
 * message. [current] is the document as it is now, or null on the first
 * publication.
 */
export function nextMetadata(current, version, effectiveFrom, mode) {
  if (mode !== 'mandatory' && mode !== 'minor') {
    return { error: 'Choose --mandatory (users must accept again) or --minor (users only see a notice).' };
  }
  if (current === null) {
    if (mode !== 'mandatory') {
      return { error: 'The first published version must be --mandatory.' };
    }
    return {
      metadata: { currentVersion: version, minimumAcceptedVersion: version, requiresReacceptance: true, effectiveFrom },
    };
  }
  if (!Number.isInteger(current.currentVersion) || !Number.isInteger(current.minimumAcceptedVersion)) {
    return { error: 'policies/privacy exists but has no valid currentVersion or minimumAcceptedVersion; fix it in the console first.' };
  }
  if (version <= current.currentVersion) {
    return { error: `Version ${version} is not newer than the current version ${current.currentVersion}.` };
  }
  return {
    metadata: {
      currentVersion: version,
      minimumAcceptedVersion: mode === 'mandatory' ? version : current.minimumAcceptedVersion,
      requiresReacceptance: mode === 'mandatory',
      effectiveFrom,
    },
  };
}
