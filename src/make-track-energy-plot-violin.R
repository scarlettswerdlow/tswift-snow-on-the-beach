library(tidyverse)
library(taylor)
library(extrafont)

args = commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("Three arguments must be supplied: (filepath to processed tracks), (filepath to raw albums), and (filepath to save plot).n", call. = FALSE)
}
tracks_analytics_fp <- args[1]
albums_raw_fp <- args[2]
plot_fp <- args[3]

tracks_analytics_df <- read_csv(tracks_analytics_fp)
albums_raw_df <- read_csv(albums_raw_fp)

# Violin plot
p <- tracks_analytics_df %>%
  left_join(
    albums_raw_df[c('album_name', 'release_date')],
    by = 'album_name'
  ) %>%
  select(
    track_name, track_energy, track_energy_outlier, album_name, release_date
  ) %>%
  ggplot(
    aes(
      x = reorder(album_name, release_date), 
      y = track_energy
    )
  ) +
  geom_violin(
    aes(fill = album_name),
    alpha = 0.1,
    color = NA
  ) +
  geom_dotplot(
    aes(fill = album_name),
    alpha = 0.3,
    binaxis = 'y',
    color = NA,
    dotsize = .8,
    stackdir = 'center'
  ) +
  geom_dotplot(
    data = function(x) subset(x, track_energy_outlier),
    aes(color = album_name),
    binaxis = 'y',
    dotsize = .8,
    fill = NA,
    stackdir = 'center',
    stroke = 1
  ) +
  geom_text(
    data = function(x) subset(x, track_energy_outlier & album_name != 'Lover' & album_name != 'folklore'),
    aes(label = str_wrap(track_name, width = 20)),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    hjust = 'right',
    nudge_x = -0.2
  ) +
  geom_text(
    data = function(x) subset(x, track_energy_outlier & album_name == 'Lover' & str_detect(track_name, 'Soon')),
    aes(label = str_wrap("Soon You'll Get Better", width = 10)),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    vjust = 'top',
    nudge_y = 0.1
    # hjust = 'right',
    # nudge_x = -0.2
  ) +
  geom_text(
    data = function(x) subset(x, track_energy_outlier & album_name == 'Lover' & str_detect(track_name, 'Soon', negate = TRUE)),
    aes(label = str_wrap(track_name, width = 10)),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    vjust = 'bottom',
    nudge_y = -0.1
    # hjust = 'right',
    # nudge_x = -0.2
  ) +
  geom_text(
    data = function(x) subset(x, track_energy_outlier & album_name == 'folklore'),
    aes(label = str_wrap(track_name, width = 10)),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    vjust = 'bottom',
    nudge_y = -0.035
    # hjust = 'right',
    # nudge_x = -0.2
  ) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  ggtitle('Taylor Swift Song Energy') +
  xlab('Era') +
  ylab('Song Energy') +
  scale_color_albums() +
  scale_fill_albums() +
  theme_minimal() +
  theme(
    legend.position = 'none',
    text = element_text(family = 'Andale Mono', size = 25),
    plot.title = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.x = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.y = element_text(margin = margin(0, 10, 0, 10))
  )

extrafont::loadfonts()
ggsave(
  plot = p,
  filename = plot_fp, 
  device = 'jpeg',
  width = 18,
  height = 12,
  units = 'in',
  dpi = 600
)
