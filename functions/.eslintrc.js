module.exports = {
  env: {
    es2022: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2022, // ECMAScript 2022
    sourceType: "module",
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "max-len": ["error", {"code": 120}], // Aumenta el límite a 120
  },
  overrides: [
    {
      files: ["**/*.spec.js", "**/*.test.js"],
      env: {
        mocha: true,
      },
      rules: {
        // Puedes desactivar algunas reglas en tus tests si lo consideras necesario
      },
    },
  ],
  globals: {},
};
