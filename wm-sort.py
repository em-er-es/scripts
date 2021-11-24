#!/usr/bin/env python3
import gi
gi.require_version('Wnck', '3.0')
from gi.repository import Wnck
import re
import yaml
import argparse

def main():
		parser = argparse.ArgumentParser(description = 'Sort windows according to regex patterns')
		parser.add_argument('-l', '--load', dest = 'filename_load', nargs = 1, type = str, help = 'Load YAML configuration file')
		parser.add_argument('-s', '--save', dest = 'filename_save', nargs = 1, type = str, help = 'Save YAML configuration file')
		parser.add_argument('-v', '--verbose', dest = 'verbose', default = 0, nargs = '?', type = int, help = 'Verbosity level')
		arguments = parser.parse_args()

		filename_save = arguments.filename_save
		filename_load = arguments.filename_load
		if filename_save is not None:
			filename_load = ''
		verbose = arguments.verbose

		if verbose is None:
			verbose = 1

		screen = Wnck.Screen.get_default()
		screen.force_update()
		active_workspace = screen.get_active_workspace()
		all_windows = screen.get_windows()

		# Load
		if filename_load is not None and len(filename_load) > 0:
			file = filename_load[0]
			data = ''
			with open(file, 'r') as stream:
				try:
					data = (yaml.load(stream))
				except Exception as exc:
					print(exc)
			prefix = ''
			suffix = ''
			assignment = {}
			for k, v in data.items():
				if verbose > 1:
					print(k, v, '\n')
				if k == "assignment":
					assignment = v
				elif k == "prefix":
					prefix = v
				elif k == "suffix":
					suffix = v

			if verbose > 0:
				print(file + ' loaded')

		else:
		# Internal
#			suffix = " .* - Mozilla Firefox"
#			suffix = " .* \xe2\x80\x94 Mozilla Firefox"
			prefix = ''
			suffix = " .* Mozilla Firefox"
			assignment = {
				0: [],
				1: ["^\[News\]"],
				2: ["^\[Linux\]", "^\[Work\]"],
				3: [],
				4: ["^\[IM\]"],
				5: ["^\[Downloads\]",],
				6: ["^\[Audio\]",],
				7: ["^\[Video [A-Z]\]",],
				8: ["^\[Games\]",],
			}
		# Update
		for key, entry in assignment.items():
			generated = []
			for subentry in entry:
				if verbose > 2:
					print(subentry, end = " -> ")
				subentry = prefix + subentry + suffix
				if verbose > 2:
					print(subentry)
				generated.append(subentry)
			assignment.update({key: generated})
		if verbose > 1:
			print(assignment)

		# Save
		if filename_save is not None and len(filename_save) > 0:
			data = {"suffix": suffix, "assignment": assignment}
			file = filename_save[0]
			with open(file, 'w') as output:
				try:
					yaml.dump(data, output, default_flow_style = False)
				except Exception as exc:
					print(exc)
			if verbose > 1:
				for k, v in data.items():
					print(k, v, '\n')
			if verbose > 0:
				print(file + ' saved')

		rearranged_windows = []
		for window in all_windows:
			name = window.get_name()
			rearranged_windows.append(window)

			for workspace, patterns in assignment.items():
				for pattern in patterns:
					regex_pattern = re.compile(pattern)
					if regex_pattern.fullmatch(name):
						previous = window.get_workspace()
						window.move_to_workspace(screen.get_workspace(workspace))
						if verbose > 1:
							print(name + ": (" + previous.get_name() + ": " + str(previous.get_number()) + ")" + " -> " + str(workspace) + " (" + str(workspace + 1) + ")")
						elif verbose > 0:
							print(name + " -> " + str(workspace))

if __name__ == "__main__":
	main()
