module.exports = {
  extends: ['airbnb-typescript/base', 'plugin:prettier/recommended'],
  plugins: ['prettier', 'import'],
  rules: {
    'prettier/prettier': ['error'],
    'import/prefer-default-export': 'off',
  },
  settings: {
    'import/resolver': {
      typescript: {}, // this loads <rootdir>/tsconfig.json to eslint
      node: {
        extensions: ['.ts'],
      },
    },
  },
  env: {
    'jest/globals': true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: './tsconfig.eslint.json',
    ecmaVersion: 2022, // Allows for the parsing of modern ECMAScript features
    sourceType: 'module', // Allows for the use of imports
  },
};
