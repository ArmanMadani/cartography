#! usr/bin/env python

"""
Quick script to create region seed file based on 4 initial coordinates 
"""

import pandas as pd

# Bounding coordinates for SF Bay Area
lower_bl = 37.729927
upper_bl = 37.787322

western_bl = -122.505204
eastern_bl = -122.389064

# Changes to initial lats/longs
delta = 0.0005

class Region:

	def __init__(self, lower_bl, upper_bl, western_bl, eastern_bl, delta):
		self.lower_bl = lower_bl
		self.upper_bl = upper_bl
		self.western_bl = western_bl
		self.eastern_bl = eastern_bl
		self.delta = delta

	def get_lats(self):
		"""
		Get latitudes from the geographic area
		"""
		position = self.lower_bl
		latitudes = []
		while position <= self.upper_bl:
			latitudes += [round(position, 6)] # Need to truncate floating pt number
			position += self.delta
		return latitudes

	def get_longs(self):
		"""
		Get longitudes from the geographic area
		"""
		position = self.western_bl
		longitudes = []
		while position <= self.eastern_bl:
			longitudes += [round(position, 6)] # Need to truncate floating pt number
			position += self.delta
		return longitudes

	def area(self, lats, longs):
		"""
		Calculate the number of lat/longs to observe in geographic region
		"""
		return len(lats) * len(longs)

	def zip_coordinates(self, lats, longs):
		"""
		Generate lat-long pairs from previously generated lists of lats and 
		longs
		"""
		zip_lats = lats * len(longs)
		zip_longs = longs * len(lats)
		coordinates = set(zip(zip_lats, zip_longs))
		return list(coordinates)

	def create_dataframe(self, coordinates):
		"""
		Saves the coordinates to a dataframe
		"""
		columns = ['latitude', 'longitude']
		df = pd.DataFrame(data = coordinates, columns = columns)
		return df

	def save_dataframe(self, df, filename):
		"""
		Saves dataframe to a local CSV file
		"""
		name = '../data/%s.csv' % filename
		df.to_csv(name, sep = ',', index = False)

if __name__ == '__main__':
	region = Region(lower_bl, upper_bl, western_bl, eastern_bl, delta)
	lats, longs = region.get_lats(), region.get_longs()
	coordinates = region.zip_coordinates(lats, longs)
	coordinate_df = region.create_dataframe(coordinates)
	region.save_dataframe(coordinate_df, 'sfbayarea')