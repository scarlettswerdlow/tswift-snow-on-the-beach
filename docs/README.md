> Like snow on the beach, weird but fuckin' beautiful

In this morsel of Taylor Swift data science, I demonstrate different ways to visualize outliers in a dataset. While a box plot is the go-to plot for visualizing outliers, I find it requires much more explanation and is therefore less intuitive than the plots I show here.

## The Data

All the data comes from the Spotify API. You can build the datasets yourself using the [Golden](https://github.com/scarlettswerdlow/tswift-golden) repo. In particular, I focus on the following features, which Spotify defines as follows:

- Track length: Self-explanatory
- Track loudness: The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db.
- Track valence: A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry).
- Track key: The key the track is in. Integers map to pitches using standard Pitch Class notation. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on. If no key was detected, the value is -1.
- Track time signature: An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of "3/4", to "7/4".

I limit my analysis to Taylor's studio albums (no singles, compilations, or albums Taylor appears on). I focus on the original albums versus Taylor's versions because I want to explore any changes in Taylor's voice over time, which the re-recordings might mask. I do not use the deluxe versions of albums, but maybe I will repeat the analysis with them to see if anything changes.

While most of the plots I show are broken down by era, I identify outliers based on the discography. For example, **Dear John** is an outlier in terms of track length because it is unusually long across all of Taylor's songs; not because it is usually long for **Speak Now** (it's not). For continuous numeric values, outliers are defined as values more than two standard deviations away from the mean. For categorical values, outliers are defined as values occuring less than 5 percent of the time.

## Violin Plots

![Song Length](/assets/track-length-outliers.jpeg)

A violin plot makes it easy to spot outliers (**Dear John** clocks in at 6 minutes 43 seconds), while also emphasizing the entire distribution of data. In this case, by plotting over a category, we see when outliers are clustered in a certain category (four of Taylor's six unusually long songs are on **Speak Now**), and we can pick out categories with unique distributions (unlike other albums, all songs on **reputation** are about the same length).

## Point Plots

![Song Loudness](/assets/track-loudness-outliers.jpeg)

Like a violin plot, a point plot highlights outliers. Rather than emphasize the entire distribution of data, though, this plot draws more attention to the average value, which I have further highlighted by filling in the median value in each category. All together, this plot tells the story that Taylor's songs are getting quieter over time, with all of her unusually quiet songs on more recent albums (two of six are on **folklore** and the remainder on **Midnights**).

### Compare and Contrast

Both a violin plot and point plot are suitable choices for visualizing outliers. Which one you choose depends on the story you are trying to tell. For example, here is the same data on track valence (positivity) visualized two different ways:

![Song Valence - Violin](/assets/track-valence-outliers-violin.jpeg) ![Song Valence - Point](/assets/track-valence-outliers-dot.jpeg)

Personally, I prefer the violin plot in this case. It captures the overall outliers, and it emphasizes those songs are also often outliers on their albums (**Picture to Burn**, **Hey Stephen**, **Shake It Off**, and **Closure**). Maybe, though, the point plot is better at communicating that **1989** and **Lover** are relatively happy and cheerful albums, whereas **Midnights** is relatively sadder.

## Lollipop Plots

A lollipop plot is useful for focusing on the difference between a given value and the modal (or most common) value. Almost all of Taylor's songs are written in 4 time signature. The lollipop plot gives no weight to those songs and instead puts all emphasis on the exceptions. The two songs written in 5 time signature (**tolerate it** and **closure**) both come from **evermore**.

![Song Time Signature](/assets/track-time-signature-outliers.jpeg)

## Circular Bar Plot

A circular bar plot is not a common way to visualize outliers. In fact, circular plots are almost always bad: they tend to be unnecessarily complicated and difficult to interpret.

Circular plots are only appropriate if the underlying data is circular: if the data has no start or end and loops back on itself. Examples of circular data include the time of day as shown on a clock and the directions on a compass. It also includes musical keys as represented by the Circle of Fifths, a way of organizing the 12 pitches as a sequence such that the most closely related key signatures are next to one another. That is why a circular bar plot is the perfect way to explore outlier keys in Taylor's songs.

![Song Key](/assets/track-key-outliers-all-data.jpeg)

Overall, Taylor's music is mostly in C, G, and D which (along with A) are the most common keys in pop music. She also has a strong showing in E, which is relatively convenient for guitar (but not piano). Her outliers range from B to E♭. Broken down by era, we see the outliers are relatively clustered on **Fearless**, **folklore**, and **evermore**. Also, **Speak Now** and **Red** stand out for their use of E (more guitar?), and **reputation** and **Lover** are more consistely pop at least in terms of key.

![Song Key by Era](/assets/track-key-outliers-by-era.jpeg)

I had not heard of the Circle of Fifths before this weekend. My husband, who is a musician, suggested it when I was struggling to visualize Taylor's song keys in a way that told any story at all -- let alone one about anomalies. Let this be a reminder that a data scientist should always consult subject matter experts.
