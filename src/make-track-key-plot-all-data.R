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

plot_df <- tracks_analytics_df %>%
  left_join(
    albums_raw_df[c('album_name', 'release_date')],
    by = 'album_name'
  ) %>%
  select(
    track_name, track_mode, track_key, album_name, release_date
  ) %>%
  mutate(
    track_mode_recoded = recode_factor(
      factor(track_mode),
      '1' = 'Major',
      '0' = 'Minor',
      .ordered = TRUE
    ),
    # Recode track key based on https://en.wikipedia.org/wiki/Pitch_class
    # Order based on https://en.wikipedia.org/wiki/Circle_of_fifths
    track_key_recoded = if_else(
      condition = track_mode == 0,   # Minor,
      true = recode_factor(
        track_key,
        '9' = 'C/Am',
        '4' = 'G/Em',
        '11' = 'D/Bm',
        '6' = 'A/F♯m',
        '1' ='E/C♯m',
        '8' = 'B/A♭m',
        '3' = 'F♯/E♭m',
        '10' = 'C♯/B♭m',
        '5' = 'A♭/Fm',
        '0' = 'E♭/Cm',
        '7' = 'B♭/Gm',
        '2' = 'F/Dm',
        .ordered = TRUE
      ),
      false = recode_factor(
        track_key,
        '0' = 'C/Am',
        '7' = 'G/Em',
        '2' = 'D/Bm',
        '9' = 'A/F♯m',
        '4' = 'E/C♯m',
        '11' = 'B/A♭m',
        '6' = 'F♯/E♭m',
        '1' = 'C♯/B♭m',
        '8' = 'A♭/Fm',
        '3' = 'E♭/Cm',
        '10' = 'B♭/Gm',
        '5' = 'F/Dm',
        .ordered = TRUE
      ),
    )
  )

p <- plot_df %>%
  group_by(track_mode_recoded, track_key_recoded) %>%
  summarize(n = n()) %>%
  ggplot(
    aes(
      x = track_key_recoded, 
      y = n
    )
  ) +
  geom_col(aes(fill = track_mode_recoded)) +
  coord_polar(start = (23/12)*pi, direction = 1) +
  scale_y_continuous(
    limits = c(-5, 30),
    expand = c(0, 0),
    breaks = c(0, 5, 10, 15, 20, 25, 30)
  ) + 
  scale_fill_manual(values = c("#B8396B", "#76BAE0")) +
  ggtitle('Taylor Swift Song Keys') +
  xlab('') +
  ylab('') +
  theme_minimal() +
  theme(
    text = element_text(family = 'Andale Mono', size = 25),
    axis.text.x = element_text(family = 'Arial Unicode MS', size = 12),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.x = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.y = element_text(margin = margin(0, 10, 0, 10)),
    legend.title = element_blank(),
    legend.position = "bottom"
  )

extrafont::loadfonts()
ggsave(
  plot = p,
  filename = plot_fp, 
  device = 'jpeg',
  width = 8,
  height = 8,
  units = 'in',
  dpi = 600
)
