import pandas as pd
import numpy as np

################################################################################
#                                                                              #
#                               Global variables                               #
#                                                                              #
################################################################################

ALBUMS = [
    'Taylor Swift', 'Fearless', 'Speak Now', 'Red', '1989', 'reputation',
    'Lover', 'folklore', 'evermore', 'Midnights'
]

TO_TEST = {
    'track_length_ms': 'z_score',
    'track_key': 'prop',
    'track_loudness': 'z_score',
    'track_time_signature': 'prop',
    'track_energy': 'z_score',
    'track_valence': 'z_score'
}

################################################################################
#                                                                              #
#                                    Functions                                 #
#                                                                              #
################################################################################

def read_data(fp):
    df = pd.read_csv(fp)
    return df

def filter_data_by_album(df, albums):
    df_filtered = df[df['album_name'].isin(albums)].copy()
    return df_filtered

def flag_outliers_z_score(series):
    z_scores = (series - series.mean())/series.std()
    flags = np.where(
        (z_scores <= -2) | (z_scores >= 2),
        True,
        False
    )
    return flags

def flag_outliers_prop(series):
    props = pd.merge(
        left = series,
        right = series.value_counts(normalize = True),
        left_on = series.name,
        right_index = True
    )
    props['flag'] = np.where(
        props['proportion'] < 0.05,
        True,
        False
    )
    return props['flag']

def main(raw_tracks_fp, processed_tracks_fp, verbose):
    tracks_df = read_data(raw_tracks_fp)
    tracks_df_filtered = filter_data_by_album(tracks_df, ALBUMS)
    if verbose: print('Finding outliers')
    for key, value in TO_TEST.items():
        new_col = f'{key}_outlier'
        if value == 'z_score':
            tracks_df_filtered[new_col] = flag_outliers_z_score(tracks_df_filtered[key])
        elif value == 'prop':
            tracks_df_filtered[new_col] = flag_outliers_prop(tracks_df_filtered[key])
    if verbose: print('Found outliers')
    tracks_df_filtered.to_csv(processed_tracks_fp)

################################################################################
#                                                                              #
#                                       Main                                   #
#                                                                              #
################################################################################

if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser(description = 'Find TSwift outliers')
    parser.add_argument('--tracks_raw', required = True, help = 'Path to get raw tracks data')
    parser.add_argument('--tracks_processed', required = True, help = 'Path to save processed tracks data')
    parser.add_argument('--verbose', required = True, help = 'Print statements')
    args = parser.parse_args()

    main(
        raw_tracks_fp = args.tracks_raw, 
        processed_tracks_fp = args.tracks_processed,
        verbose = args.verbose
    )