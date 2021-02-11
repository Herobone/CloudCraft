module.exports = {
    plugins: ["eslint-comments", "promise", "unicorn"],
    extends: [
        "plugin:eslint-comments/recommended",
        "plugin:promise/recommended",
        "plugin:unicorn/recommended",
        "prettier",
    ],
    rules: {
        quotes: "off",
        "eslint-comments/disable-enable-pair": ["error", { allowWholeFile: true }],
    },
};
