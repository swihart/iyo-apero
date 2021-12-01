## remember to be in the right directory when you run this!
getwd()
##setwd("./content/project/")
library(ggplot2)
require(UpSetR)
library(hexSticker)
## https://nanx.me/blog/post/rebranding-r-packages-with-hexagon-stickers/
# sysfonts::font_add_google("Zilla Slab", "pf", regular.wt = 500)
# 
# ## https://stackoverflow.com/a/55722553/2727349
# ## needed to adjust the ~ plot.new() in original code
# blank_plot <- ggplot() + theme_void()
# hexSticker::sticker(
#   subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
#   package = "gnlrim", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
#   p_color = "#3F8CCC", h_fill = "#FFF9F2", h_color = "#3F8CCC",
#   dpi = 320, filename = "./bakeoff/featured-hex.png"
# )

#magick::image_read("man/figures/logo.png")

#rstudioapi::restartSession()

## https://color.adobe.com/explore?page=6
bg <- "#EBF4F9"
class01 <- "#A9CADD"
class02 <- "#D9564A"
class03 <- "#EFB14A"
class04 <- "#3C5E73"
# sysfonts::font_add_google("Josefin Slab", "pf", regular.wt = 600)
# ## https://stackoverflow.com/a/55722553/2727349
# ## needed to adjust the ~ plot.new() in original code
# blank_plot <- ggplot() + theme_void()
# hexSticker::sticker(
#   subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
#   package = "gnlrim", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
#   p_color = class01, h_fill = bg, h_color = class01,
#   dpi = 320, filename = "./bakeoff/featured-hex.png"
# )
# 
# blank_plot <- ggplot() + theme_void()
# hexSticker::sticker(
#   subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
#   package = "repeated", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
#   p_color = class04, h_fill = bg, h_color = class04,
#   dpi = 320, filename = "./giraffes/featured-hex.png"
# )
# 




## https://color.adobe.com/explore?page=6
bg <- "#FFECD1"
class01 <- "#001524"
class02 <- "#15616D"
class03 <- "#FF7D00"
class04 <- "#78290F"

sysfonts::font_add_google("Josefin Slab", "pf", regular.wt = 600)
blank_plot <- ggplot() + theme_void()


## https://stackoverflow.com/a/55722553/2727349
## needed to adjust the ~ plot.new() in original code

hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "gnlrim", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class02, h_fill = bg, h_color = class02,
  dpi = 320, filename = "./gnlrim/featured-hex.png"
)


hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "mvsubgaussPD", p_x = 1, p_y = 1, p_size = 6, h_size = 1.2, p_family = "pf",
  p_color = class01, h_fill = bg, h_color = class01,
  dpi = 320, filename = "./mvsubgaussPD/featured-hex.png"
)

hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "bridgedist", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class01, h_fill = bg, h_color = class01,
  dpi = 320, filename = "./bridgedist/featured-hex.png"
)


hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "rmutil", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./rmutil/featured-hex.png"
)
hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "gnlm", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./gnlm/featured-hex.png"
)
hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "repeated", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./repeated/featured-hex.png"
)
hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "growth", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./growth/featured-hex.png"
)
hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "event", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./event/featured-hex.png"
)
hexSticker::sticker(
  subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
  package = "stable", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
  p_color = class03, h_fill = bg, h_color = class03,
  dpi = 320, filename = "./stable/featured-hex.png"
)

# hexSticker::sticker(
#   subplot = blank_plot, s_x = 1, s_y = 1, s_width = 0.1, s_height = 0.1,
#   package = "palmer", p_x = 1, p_y = 1, p_size = 8, h_size = 1.2, p_family = "pf",
#   p_color = class04, h_fill = bg, h_color = class04,
#   dpi = 320, filename = "./penguins/featured-hex.png"
# )

rstudioapi::restartSession()
