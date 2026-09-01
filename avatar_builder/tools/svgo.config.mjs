/** @type {import('svgo').Config} */
export default {
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          // Preserve all IDs — fragments reference each other's IDs
          // at runtime when combined into the final SVG.
          cleanupIds: false,
        },
      },
    },
  ],
};
