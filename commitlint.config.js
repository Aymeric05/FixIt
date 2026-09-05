module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'refactor', 'perf', 'style', 'chore', 'docs', 'test', 'ci']
    ],
    'subject-case': [0], // Allow any case for the subject (useful since we use French)
  },
};
