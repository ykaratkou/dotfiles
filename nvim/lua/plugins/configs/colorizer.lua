require 'colorizer'.setup({
  '*'; -- Highlight all files, but customize some others.
  '!ruby';
  html = { names = false; } -- Disable parsing "names" like Blue or Gray
}, {
  css = true; -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
})
