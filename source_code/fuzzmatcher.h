#ifndef FUZZMATCHER_H
#define FUZZMATCHER_H

#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <string>
#include <any>
#include <string_view>
#include <vector>
#include <array>
#include <typeinfo>
#include <compare>
#include <initializer_list>
#include <queue>
#include <numeric>
#include <unordered_map>
#include <map>
#include <deque>
#include <memory>
#include <set>
#include <unordered_set>
#include <utility>
#include <algorithm>
#include <cctype>
#include <cstring>
#include <sstream>
#include <optional>
#include <filesystem>
#include <variant>
#include <cmath>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <random>
#include <charconv>
#include <iomanip>

namespace strsearch {
	static constexpr  int MAX_32BIT_INT = 2147483647;
	static constexpr  float MAX_32BIT_INT_AS_FLOAT = 2147483647.0f;
	static constexpr  void calculate_hemming_distance_2ways(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width = -1;
		int idx_counter_string_height = -1;
		int len_string_width;
		int bestbindex;
		int a_len;
		int b_len;
		int i;
		int bestresult;
		auto a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
		int bestblength;
		float a_switched;
		int len_string_height;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int result;
		float was_switched;
		int tmpresult;
		int ii;
		strings_width_iter_start = a_strings;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
			bestresult = MAX_32BIT_INT;
			bestbindex = 0;
			bestblength = 0;
			was_switched = 1;
			a_switched = 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height)) {
					strings_height_iter_start++;
					continue;
					}
				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				if ((a_len == b_len) && (astringviewtemp[0] == bstringviewtemp[0]) && (astringviewtemp == (bstringviewtemp))) {
					bestbindex = idx_counter_string_height;
					bestresult = 0.0f;
					bestblength = 1;
					was_switched = 1;
					break;
					}
				result = MAX_32BIT_INT;
				for (ii = 0; ii <= b_len - a_len; ii++) {
					tmpresult = b_len - a_len;
					for (i = 0; i <= b_len; i++) {

						if (i >= a_len) {
							break;
							}
						if (bstringviewtemp[i + ii] != astringviewtemp[i]) {
							tmpresult++;
							}
						}
					if (tmpresult < result) {
						result = tmpresult;
						}
					}
				if ((bestresult > result) || ((bestresult == result) && (((((float)b_len) / ((float)a_len))) < a_len_b_len_ratio))) {
					bestresult = result;
					bestbindex = idx_counter_string_height;
					bestblength = b_len;
					a_len_b_len_ratio = (((float)b_len) / ((float)a_len));
					was_switched = a_switched;
					}
				strings_height_iter_start++;
				}
			if (bestblength) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[bestbindex];
				result_map[vec1_mapping[idx_counter_string_width]].second = was_switched * (float)bestresult;
				}
			strings_width_iter_start++;
			}
		}

	static constexpr  void calculate_hemming_distance_1way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width = -1;
		int idx_counter_string_height;
		int len_string_width;
		int bestbindex;
		int a_len;
		int b_len;
		int i;
		int bestresult;
		auto a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
		int bestblength;
		float a_switched;
		int len_string_height;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int result;
		float was_switched;
		strings_width_iter_start = a_strings;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
			bestresult = MAX_32BIT_INT;
			bestbindex = 0;
			bestblength = 0;
			was_switched = 1;
			a_switched = 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height)) {
					strings_height_iter_start++;
					continue;
					}
				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				if ((a_len == b_len) && (astringviewtemp[0] == bstringviewtemp[0]) && (astringviewtemp == (bstringviewtemp))) {
					bestbindex = idx_counter_string_height;
					bestresult = 0.0f;
					bestblength = 1;
					was_switched = 1;
					break;
					}
				result = b_len - a_len;
				for (i = 0; i <= b_len; i++) {
					if (i >= a_len) {
						break;
						}
					if (bstringviewtemp[i] != astringviewtemp[i]) {
						result++;
						}
					}
				if ((bestresult > result) || ((bestresult == result) && ((fabs(1.0f - ((float)b_len) / ((float)a_len))) < a_len_b_len_ratio))) {
					bestresult = result;
					bestbindex = idx_counter_string_height;
					bestblength = b_len;
					a_len_b_len_ratio = fabs(1.0f - ((float)b_len) / ((float)a_len));
					was_switched = a_switched;
					}
				strings_height_iter_start++;
				}
			if (bestblength) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[bestbindex];
				result_map[vec1_mapping[idx_counter_string_width]].second = (((float)bestresult) * was_switched);
				}
			strings_width_iter_start++;
			}
		}

	static constexpr  void calculate_longest_common_substr_v1(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width = -1;
		int idx_counter_string_height = -1;
		int len_string_width;
		int bestbindex;
		int a_len;
		int b_len;
		int bestresult;
		auto a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
		int bestblength;
		float a_switched;
		int len_string_height;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int result;
		int string_difference;
		int tmpresult;
		float was_switched;
		strings_width_iter_start = a_strings;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
			bestresult = 0;
			bestbindex = 0;
			bestblength = 0;
			a_switched = 1;
			was_switched = 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height) || (len_string_height < bestresult)) {
					strings_height_iter_start++;
					continue;
					}
				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				if ((a_len == b_len) && (astringviewtemp[0] == bstringviewtemp[0]) && (astringviewtemp == (bstringviewtemp))) {
					bestbindex = idx_counter_string_height;
					bestresult = 1.0f;
					bestblength = 1;
					a_switched = 1;
					break;
					}
				result = 0;
				string_difference = b_len - a_len;
				for (int offsetindex = 0; offsetindex < string_difference; offsetindex++) {
					tmpresult = 0;
					for (int stringidex = 0; stringidex < a_len; stringidex++) {
						tmpresult += ((astringviewtemp[stringidex] == bstringviewtemp[stringidex + offsetindex]) ? 1 : 0);
						}
					if (tmpresult > result) {
						result = tmpresult;
						}
					}
				if ((bestresult < result) || ((bestresult == result) && ((fabs(1.0f - ((float)b_len) / ((float)a_len))) < a_len_b_len_ratio))) {
					bestresult = result;
					bestbindex = idx_counter_string_height;
					bestblength = b_len;
					a_len_b_len_ratio = fabs(1.0f - ((float)b_len) / ((float)a_len));
					was_switched = a_switched;
					}
				strings_height_iter_start++;
				}
			if (bestblength) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[bestbindex];
				result_map[vec1_mapping[idx_counter_string_width]].second = was_switched * (((float)bestresult) / (float)bestblength);
				}
			strings_width_iter_start++;
			}
		}


	static void constexpr   calculate_longest_common_subsequence_v2(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		float current_jaro_distance;
		float jaro_best_match;
		int* start_ptr_matrix;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int jaro_best_idx_height;
		int len_string_width;
		int len_string_height;
		int prev_row;
		int current_row;
		int j;
		int i;
		int a_len;
		int b_len;
		int last_string_len_difference;
		float a_switched;
		float was_switched;
		int last_best_result_tmp;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int* end_ptr_matrix = fake_matrix + (index_multiplier_width * 2);
		strings_width_iter_start = a_strings;
		idx_counter_string_width = -1;

		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			jaro_best_idx_height = 0;
			jaro_best_match = 0;
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			was_switched = 1;
			a_switched = 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				if ((len_string_height == len_string_width) && ((*strings_height_iter_start)[0] == (*strings_width_iter_start)[0]) && ((*strings_height_iter_start) == (*strings_width_iter_start))) {
					jaro_best_match = 100.0f;
					jaro_best_idx_height = idx_counter_string_height;
					was_switched = 1;
					break;
					}
				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				last_best_result_tmp = 0;

				start_ptr_matrix = fake_matrix;
				for (; start_ptr_matrix < end_ptr_matrix;) {
					*start_ptr_matrix++ = 0;
					}
				current_row = 0;
				prev_row = 1;
				for (i = 0; i < a_len; i++) {
					for (j = 0; j < b_len; j++) {
						if ((astringviewtemp)[i] == (bstringviewtemp)[j]) {
							fake_matrix[current_row * index_multiplier_width + j] = j == 0 ? 1 : 1 + fake_matrix[prev_row * index_multiplier_width + j - 1];
							if (fake_matrix[current_row * index_multiplier_width + j] > last_best_result_tmp) {
								last_best_result_tmp = fake_matrix[current_row * index_multiplier_width + j];
								}
							else {
								fake_matrix[current_row * index_multiplier_width + j] = 0;
								}
							}
						}
					prev_row = current_row;
					current_row = (current_row + 1) % 2;
					}
				current_jaro_distance = (((float)(last_best_result_tmp * 2)) / ((len_string_height + len_string_width))) * 100.0f;
				if ((current_jaro_distance > jaro_best_match) || (((current_jaro_distance == jaro_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_jaro_distance == jaro_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					jaro_best_match = current_jaro_distance;
					was_switched = a_switched;
					jaro_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			if (jaro_best_match > 0.0f) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[jaro_best_idx_height];
				result_map[vec1_mapping[idx_counter_string_width]].second = jaro_best_match * was_switched;
				}
			strings_width_iter_start++;
			}
		}


	static constexpr  void calculate_longest_common_subsequence_v1(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;

		int len_string_width;
		int bestbindex;
		int a_lensaved;
		float a_switched;
		float was_switched;
		float interbi_result;
		int a_len;
		int b_len;
		float interbi;
		int len_string_height;
		int i;
		int j;
		int current_row;
		int prev_row;
		int last_string_len_difference;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int idx_counter_string_width = -1;
		int idx_counter_string_height = -1;
		strings_width_iter_start = a_strings;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			interbi = -1;
			bestbindex = 0;
			a_lensaved = 0;
			a_switched = 1;
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			was_switched = 1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				if ((len_string_height == len_string_width) && ((*strings_height_iter_start)[0] == (*strings_width_iter_start)[0]) && ((*strings_height_iter_start) == (*strings_width_iter_start))) {
					interbi = 100.0f;
					bestbindex = idx_counter_string_height;
					was_switched = 1;
					break;
					}

				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				current_row = 0;
				prev_row = 1;
				for (i = a_len; i >= 0; i--) {
					for (j = b_len; j >= 0; j--) {
						if (i == a_len || j == b_len) {
							fake_matrix[current_row * index_multiplier_width + j] = 0;
							}
						else if ((i < a_len) && (j < b_len) && ((astringviewtemp[i]) == (bstringviewtemp[j]))) {
							fake_matrix[current_row * index_multiplier_width + j] = 1 + fake_matrix[prev_row * index_multiplier_width + j + 1];
							}
						else {
							if (fake_matrix[prev_row * index_multiplier_width + j] > fake_matrix[current_row * index_multiplier_width + j + 1]) {
								fake_matrix[current_row * index_multiplier_width + j] = fake_matrix[prev_row * index_multiplier_width + j];
								}
							else {
								fake_matrix[current_row * index_multiplier_width + j] = fake_matrix[current_row * index_multiplier_width + j + 1];
								}
							}
						}
					prev_row = current_row;
					current_row = (current_row + 1) % 2;
					}
				interbi_result = (((float)(fake_matrix[prev_row * index_multiplier_width] * 2)) / ((len_string_height + len_string_width))) * 100.0f;
				if ((interbi_result > interbi) || (((interbi_result == interbi) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((interbi_result == interbi) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					bestbindex = idx_counter_string_height;
					a_lensaved = len_string_width + len_string_height;
					was_switched = a_switched;
					interbi = interbi_result;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			if (a_lensaved) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[bestbindex];
				result_map[vec1_mapping[idx_counter_string_width]].second = interbi * was_switched;
				}
			strings_width_iter_start++;
			}
		}


	static void constexpr calculate_jaro_distance_2_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		float current_jaro_distance;
		float current_jaro_distance_tmp;
		float jaro_best_match;
		int* start_ptr_matrix;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int jaro_best_idx_height;
		int len_string_width;
		int len_string_height;
		int max_dist;
		int m;
		int i;
		int low;
		int high;
		int j;
		int k;
		int t;
		int last_string_len_difference;
		std::string_view current_string_width;
		std::string_view current_string_height;
		int* end_ptr_matrix = fake_matrix + (index_multiplier_width * 2);
		strings_width_iter_start = a_strings;
		idx_counter_string_width = -1;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			jaro_best_idx_height = 0;
			jaro_best_match = 0;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if ((len_string_height == len_string_width) && (current_string_height[0] == current_string_width[0]) && (current_string_height == (current_string_width))) {
					jaro_best_match = 2.0f;
					jaro_best_idx_height = idx_counter_string_height;
					break;
					}
				current_jaro_distance = 0.0f;
				for (int bafo = 0; bafo < 2; bafo++) {
					std::reverse((char*)&(strings_height_iter_start->data()[0]), (char*)&(strings_height_iter_start->data()[0]) + strings_height_iter_start->size());
					std::reverse((char*)&(strings_width_iter_start->data()[0]), (char*)&(strings_width_iter_start->data()[0]) + strings_width_iter_start->size());
					start_ptr_matrix = fake_matrix;
					for (; start_ptr_matrix < end_ptr_matrix;) {
						*start_ptr_matrix++ = 0;
						}
					max_dist = ((len_string_width > len_string_height ? len_string_width : len_string_height) / 2) - 1;
					m = 0;
					i = 0;
					low = 0;
					high = 0;
					j = 0;
					k = 0;
					t = 0;
					current_jaro_distance_tmp = 0.0f;
					for (i = 0; i < len_string_width; i++) {
						low = (i > max_dist ? i - max_dist : 0);
						high = (i + max_dist < len_string_height ? i + max_dist : len_string_height - 1);
						for (j = low; j <= high; j++) {
							if (!fake_matrix[index_multiplier_width + j] && (current_string_width[i] == current_string_height[j])) {
								fake_matrix[i] = 1;
								fake_matrix[index_multiplier_width + j] = 1;
								m++;
								break;
								}
							}
						}
					if (!m) {
						continue;
						}
					k = t = 0;
					for (i = 0; i < len_string_width; i++) {
						if (fake_matrix[i]) {
							for (j = k; j < len_string_height; j++) {
								if (fake_matrix[index_multiplier_width + j]) {
									k = j + 1;
									break;
									}
								}
							if (current_string_width[i] != current_string_height[j]) {
								t++;
								}
							}
						}
					t /= 2;
					current_jaro_distance_tmp = (((float)m) / len_string_width + ((float)m) / len_string_height + ((float)(m - t)) / m) / 3.0f;
					current_jaro_distance += current_jaro_distance_tmp;
					}
				if ((current_jaro_distance > jaro_best_match) || (((current_jaro_distance == jaro_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_jaro_distance == jaro_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					jaro_best_match = current_jaro_distance;
					jaro_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[jaro_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = jaro_best_match;
			strings_width_iter_start++;
			}
		}
	static void constexpr   calculate_jaro_winkler_distance_2_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		float current_jaro_distance;
		float current_jaro_distance_tmp;
		float jaro_best_match;
		int* start_ptr_matrix;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int jaro_best_idx_height;
		int len_string_width;
		int len_string_height;
		int max_dist;
		int m;
		int i;
		int low;
		int high;
		int j;
		int k;
		int t;
		int n;
		int last_string_len_difference;
		std::string_view current_string_width;
		std::string_view current_string_height;
		int* end_ptr_matrix = fake_matrix + (index_multiplier_width * 2);
		strings_width_iter_start = a_strings;
		idx_counter_string_width = -1;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			jaro_best_idx_height = 0;
			jaro_best_match = 0;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if ((len_string_height == len_string_width) && (current_string_height[0] == current_string_width[0]) && (current_string_height == (current_string_width))) {
					jaro_best_match = 2.0f;
					jaro_best_idx_height = idx_counter_string_height;
					break;
					}
				current_jaro_distance = 0.0f;
				for (int bafo = 0; bafo < 2; bafo++) {
					std::reverse((char*)&(strings_height_iter_start->data()[0]), (char*)&(strings_height_iter_start->data()[0]) + strings_height_iter_start->size());
					std::reverse((char*)&(strings_width_iter_start->data()[0]), (char*)&(strings_width_iter_start->data()[0]) + strings_width_iter_start->size());
					start_ptr_matrix = fake_matrix;
					for (; start_ptr_matrix < end_ptr_matrix;) {
						*start_ptr_matrix++ = 0;
						}
					max_dist = ((len_string_width > len_string_height ? len_string_width : len_string_height) / 2) - 1;
					m = 0;
					i = 0;
					low = 0;
					high = 0;
					j = 0;
					k = 0;
					t = 0;
					current_jaro_distance_tmp = 0.0f;
					for (i = 0; i < len_string_width; i++) {
						low = (i > max_dist ? i - max_dist : 0);
						high = (i + max_dist < len_string_height ? i + max_dist : len_string_height - 1);
						for (j = low; j <= high; j++) {
							if (!fake_matrix[index_multiplier_width + j] && (current_string_width[i] == current_string_height[j])) {
								fake_matrix[i] = 1;
								fake_matrix[index_multiplier_width + j] = 1;
								m++;
								break;
								}
							}
						}
					if (!m) {
						continue;
						}
					k = t = 0;
					for (i = 0; i < len_string_width; i++) {
						if (fake_matrix[i]) {
							for (j = k; j < len_string_height; j++) {
								if (fake_matrix[index_multiplier_width + j]) {
									k = j + 1;
									break;
									}
								}
							if (current_string_width[i] != current_string_height[j]) {
								t++;
								}
							}
						}
					t /= 2;
					current_jaro_distance_tmp = (((float)m) / len_string_width + ((float)m) / len_string_height + ((float)(m - t)) / m) / 3.0f;
					n = 0;
					for (i = 0; i < (len_string_width >= 4 ? 4 : len_string_width); i++) {
						if ((i < len_string_height) && (current_string_width[i] == current_string_height[i])) {
							n++;
							}
						else {
							break;
							}
						}
					current_jaro_distance_tmp = current_jaro_distance_tmp + (float)n * 0.1f * (1.0f - current_jaro_distance_tmp);
					current_jaro_distance += current_jaro_distance_tmp;
					}
				if ((current_jaro_distance > jaro_best_match) || (((current_jaro_distance == jaro_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_jaro_distance == jaro_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					jaro_best_match = current_jaro_distance;
					jaro_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[jaro_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = jaro_best_match;
			strings_width_iter_start++;
			}
		}
	static void constexpr   calculate_jaro_winkler_distance_1_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		float current_jaro_distance;
		float jaro_best_match;
		int* start_ptr_matrix;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int jaro_best_idx_height;
		int len_string_width;
		int len_string_height;
		int max_dist;
		int m;
		int i;
		int low;
		int high;
		int j;
		int k;
		int t;
		int n;
		int last_string_len_difference;
		std::string_view current_string_width;
		std::string_view current_string_height;
		int* end_ptr_matrix = fake_matrix + (index_multiplier_width * 2);
		strings_width_iter_start = a_strings;
		idx_counter_string_width = -1;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			jaro_best_idx_height = 0;
			jaro_best_match = 0;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if ((len_string_height == len_string_width) && (current_string_height[0] == current_string_width[0]) && (current_string_height == (current_string_width))) {
					jaro_best_match = 1.0f;
					jaro_best_idx_height = idx_counter_string_height;
					break;
					}
				start_ptr_matrix = fake_matrix;
				for (; start_ptr_matrix < end_ptr_matrix;) {
					*start_ptr_matrix++ = 0;
					}
				max_dist = ((len_string_width > len_string_height ? len_string_width : len_string_height) / 2) - 1;
				m = 0;
				i = 0;
				low = 0;
				high = 0;
				j = 0;
				k = 0;
				t = 0;
				current_jaro_distance = 0.0f;
				for (i = 0; i < len_string_width; i++) {
					low = (i > max_dist ? i - max_dist : 0);
					high = (i + max_dist < len_string_height ? i + max_dist : len_string_height - 1);
					for (j = low; j <= high; j++) {
						if (!fake_matrix[index_multiplier_width + j] && (current_string_width[i] == current_string_height[j])) {
							fake_matrix[i] = 1;
							fake_matrix[index_multiplier_width + j] = 1;
							m++;
							break;
							}
						}
					}
				if (!m) {
					strings_height_iter_start++;
					continue;
					}
				k = t = 0;
				for (i = 0; i < len_string_width; i++) {
					if (fake_matrix[i]) {
						for (j = k; j < len_string_height; j++) {
							if (fake_matrix[index_multiplier_width + j]) {
								k = j + 1;
								break;
								}
							}
						if (current_string_width[i] != current_string_height[j]) {
							t++;
							}
						}
					}
				t /= 2;
				current_jaro_distance = (((float)m) / (float)len_string_width + ((float)m) / (float)len_string_height + ((float)(m - t)) / m) / 3.0f;
				n = 0;
				for (i = 0; i < (len_string_width >= 4 ? 4 : len_string_width); i++) {
					if ((i < len_string_height) && (current_string_width[i] == current_string_height[i])) {
						n++;
						}
					else {
						break;
						}
					}
				current_jaro_distance = current_jaro_distance + (float)n * 0.1f * (1.0f - current_jaro_distance);
				if ((current_jaro_distance > jaro_best_match) || (((current_jaro_distance == jaro_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_jaro_distance == jaro_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					jaro_best_match = current_jaro_distance;
					jaro_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[jaro_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = jaro_best_match;
			strings_width_iter_start++;
			}
		}
	static void constexpr   calculate_jaro_distance_1_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		float current_jaro_distance;
		float jaro_best_match;
		int* start_ptr_matrix;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int jaro_best_idx_height;
		int len_string_width;
		int len_string_height;
		int max_dist;
		int m;
		int i;
		int low;
		int high;
		int j;
		int k;
		int t;
		int last_string_len_difference;
		std::string_view current_string_width;
		std::string_view current_string_height;
		int* end_ptr_matrix = fake_matrix + (index_multiplier_width * 2);
		strings_width_iter_start = a_strings;
		idx_counter_string_width = -1;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			jaro_best_idx_height = 0;
			jaro_best_match = 0;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if (!len_string_height) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if ((len_string_height == len_string_width) && (current_string_height[0] == current_string_width[0]) && (current_string_height == (current_string_width))) {
					jaro_best_match = 1.0f;
					jaro_best_idx_height = idx_counter_string_height;
					break;
					}
				start_ptr_matrix = fake_matrix;
				for (; start_ptr_matrix < end_ptr_matrix;) {
					*start_ptr_matrix++ = 0;
					}
				max_dist = ((len_string_width > len_string_height ? len_string_width : len_string_height) / 2) - 1;
				m = 0;
				i = 0;
				low = 0;
				high = 0;
				j = 0;
				k = 0;
				t = 0;
				current_jaro_distance = 0.0f;
				for (i = 0; i < len_string_width; i++) {
					low = (i > max_dist ? i - max_dist : 0);
					high = (i + max_dist < len_string_height ? i + max_dist : len_string_height - 1);
					for (j = low; j <= high; j++) {
						if (!fake_matrix[index_multiplier_width + j] && (current_string_width[i] == current_string_height[j])) {
							fake_matrix[i] = 1;
							fake_matrix[index_multiplier_width + j] = 1;
							m++;
							break;
							}
						}
					}
				if (!m) {
					strings_height_iter_start++;
					continue;
					}
				k = t = 0;
				for (i = 0; i < len_string_width; i++) {
					if (fake_matrix[i]) {
						for (j = k; j < len_string_height; j++) {
							if (fake_matrix[index_multiplier_width + j]) {
								k = j + 1;
								break;
								}
							}
						if (current_string_width[i] != current_string_height[j]) {
							t++;
							}
						}
					}
				t /= 2;
				current_jaro_distance = (((float)m) / (float)len_string_width + ((float)m) / (float)len_string_height + ((float)(m - t)) / m) / 3.0f;
				if ((current_jaro_distance > jaro_best_match) || (((current_jaro_distance == jaro_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_jaro_distance == jaro_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0))))) {
					jaro_best_match = current_jaro_distance;
					jaro_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[jaro_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = jaro_best_match;
			strings_width_iter_start++;
			}
		}
	static constexpr  void calculate_longest_common_substring(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		bool one_sequence_only,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width = -1;
		int idx_counter_string_height = -1;
		int len_string_width = 0;
		strings_width_iter_start = a_strings;
		int bestbindex = 0;
		int a_len = 0;
		int b_len = 0;
		int bestresult = 0;
		auto a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
		int bestblength = 0;
		float a_switched;
		int len_string_height;
		std::string_view astringviewtemp;
		std::string_view bstringviewtemp;
		int result;
		int result1 = 0;
		int string_difference;
		int tmpresult;
		int tmpresult_tmp;
		int last_best_index;
		bool stop_now;
		float was_switched;
		int offsetindex = 0;
		int stringidex = 0;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			strings_height_iter_start = b_strings;
			idx_counter_string_height = -1;
			a_len_b_len_ratio = MAX_32BIT_INT_AS_FLOAT;
			bestresult = 0;
			bestbindex = 0;
			bestblength = 0;
			a_switched = 1;
			was_switched = 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height)) {
					strings_height_iter_start++;
					continue;
					}
				if (len_string_width > len_string_height) {
					a_len = len_string_height;
					b_len = len_string_width;
					astringviewtemp = (*strings_height_iter_start);
					bstringviewtemp = (*strings_width_iter_start);
					a_switched = -1;
					}
				else {
					a_len = len_string_width;
					b_len = len_string_height;
					astringviewtemp = (*strings_width_iter_start);
					bstringviewtemp = (*strings_height_iter_start);
					a_switched = 1;
					}
				if ((a_len == b_len) && (astringviewtemp[0] == bstringviewtemp[0]) && (astringviewtemp == (bstringviewtemp))) {
					bestbindex = idx_counter_string_height;
					bestresult = 1.0f;
					bestblength = 1;
					was_switched = 1;
					break;
					}
				result = 0;

				string_difference = b_len - a_len;
				last_best_index = 0;
				for (offsetindex = 0; offsetindex < string_difference; offsetindex++) {
					tmpresult = 0;
					tmpresult_tmp = 0;
					for (stringidex = 0; stringidex < a_len; stringidex++) {
						if ((astringviewtemp[stringidex] != bstringviewtemp[stringidex + offsetindex])) {
							if (tmpresult_tmp > tmpresult) {
								tmpresult = tmpresult_tmp;
								}
							tmpresult_tmp = 0;
							}
						else {
							tmpresult_tmp++;
							last_best_index = stringidex + offsetindex;
							}

						}
					if (tmpresult > result) {
						result = tmpresult;
						}
					if (result == a_len) {
						break;
						}
					}


				if (!one_sequence_only) {
					result1 = 0;
					//last_best_index1 = 0;
					stop_now = false;
					for (offsetindex = 0; offsetindex < string_difference && !stop_now; offsetindex++) {
						tmpresult = 0;
						tmpresult_tmp = 0;

						for (stringidex = a_len - 1; stringidex >= 0; stringidex--) {

							if ((astringviewtemp[stringidex] != bstringviewtemp[stringidex + offsetindex])) {
								if (tmpresult_tmp > tmpresult) {
									tmpresult = tmpresult_tmp;
									}
								tmpresult_tmp = 0;
								}

							else {
								tmpresult_tmp++;
								}
							if (stringidex + offsetindex == last_best_index) {
								stop_now = true;
								break;
								}
							}
						if (tmpresult > result1) {
							result1 = tmpresult;
							}
						if (result1 == a_len) {
							break;
							}
						}
					}
				result += result1;
				if ((bestresult < result) || ((bestresult == result) && ((fabs(((float)b_len) / ((float)a_len))) < a_len_b_len_ratio))) {
					bestresult = result;
					bestbindex = idx_counter_string_height;
					bestblength = b_len;
					a_len_b_len_ratio = fabs(((float)b_len) / ((float)a_len));
					was_switched = a_switched;
					}
				strings_height_iter_start++;
				}
			if (bestblength) {
				result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[bestbindex];
				result_map[vec1_mapping[idx_counter_string_width]].second = was_switched * (float)bestresult;
				}
			strings_width_iter_start++;
			}
		}
	static constexpr void calculate_levenshtein_distance_1_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		const int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int leven_best_idx_height;
		int leven_best_match;
		int len_string_width;
		int len_string_height;
		int last_string_len_difference;
		int current_levenshtein_distance;
		int next_value_check;
		bool stop_now;
		std::string_view current_string_width;
		std::string_view current_string_height;
		idx_counter_string_width = -1;
		strings_width_iter_start = a_strings;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			leven_best_idx_height = 0;
			leven_best_match = MAX_32BIT_INT;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height) || (abs(len_string_width - len_string_height) > leven_best_match)) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if (len_string_width == len_string_height && current_string_height[0] == current_string_width[0] && (current_string_width == (current_string_height))) {
					leven_best_idx_height = idx_counter_string_height;
					leven_best_match = 0;
					break;
					}
				stop_now = false;
				next_value_check = 0;
				for (int i = 1; i <= len_string_height && !stop_now; ++i) {
					next_value_check += (index_multiplier_width + 1);
					for (int j = 1; j <= len_string_width; ++j) {
						fake_matrix[i * index_multiplier_width + j] = std::min(std::min(fake_matrix[(i - 1) * index_multiplier_width + j] + 1, fake_matrix[i * index_multiplier_width + (j - 1)] + 1), fake_matrix[(i - 1) * index_multiplier_width + j - 1] + (((current_string_height)[i - 1] == (current_string_width)[j - 1]) ? 0 : 1));
						if (i * index_multiplier_width + j != next_value_check) {
							continue;
							}
						if (fake_matrix[i * index_multiplier_width + j] + 1 > leven_best_match) {
							stop_now = true;
							break;
							}
						}
					}
				if (stop_now) {
					strings_height_iter_start++;
					continue;
					}
				current_levenshtein_distance = (fake_matrix[len_string_height * index_multiplier_width + len_string_width]);
				if (((current_levenshtein_distance) < leven_best_match) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0)))) {
					leven_best_match = current_levenshtein_distance;
					leven_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				if ((leven_best_match == 1) && (last_string_len_difference == -1)) {
					break;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[leven_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = (float)leven_best_match;
			strings_width_iter_start++;
			}
		}
	static constexpr void calculate_levenshtein_distance_2_ways(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		const int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int i;
		int j;
		int idx_counter_string_height;
		int leven_best_idx_height;
		int leven_best_match;
		int len_string_width;
		std::string_view current_string_width;
		std::string_view current_string_height;
		int current_levenshtein_distance;
		int len_string_height;
		int last_string_len_difference;
		int len_string_width_m1;
		bool stop_now;
		int next_value_check;
		int len_string_height_m1;
		strings_width_iter_start = a_strings;
		int idx_counter_string_width = -1;
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			leven_best_idx_height = 0;
			leven_best_match = MAX_32BIT_INT;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			len_string_width_m1 = len_string_width - 1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height) || (abs(len_string_width - len_string_height) > leven_best_match)) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if (len_string_width == len_string_height && current_string_height[0] == current_string_width[0] && (current_string_width == (current_string_height))) {
					leven_best_idx_height = idx_counter_string_height;
					leven_best_match = 0;
					break;
					}
				stop_now = false;
				next_value_check = 0;
				current_levenshtein_distance = 0;
				for (i = 1; i <= len_string_height && !stop_now; ++i) {
					next_value_check += (index_multiplier_width + 1);
					for (j = 1; j <= len_string_width; ++j) {
						fake_matrix[i * index_multiplier_width + j] = std::min(std::min(fake_matrix[(i - 1) * index_multiplier_width + j] + 1, fake_matrix[i * index_multiplier_width + (j - 1)] + 1), fake_matrix[(i - 1) * index_multiplier_width + j - 1] + (((current_string_height)[i - 1] == (current_string_width)[j - 1]) ? 0 : 1));
						if (i * index_multiplier_width + j != next_value_check) {
							continue;
							}
						if (fake_matrix[i * index_multiplier_width + j] + 1 > leven_best_match) {
							stop_now = true;
							break;
							}
						}
					}
				if (stop_now) {
					strings_height_iter_start++;
					continue;
					}
				current_levenshtein_distance += (fake_matrix[(len_string_height)*index_multiplier_width + len_string_width]);
				if (current_levenshtein_distance > leven_best_match) {
					strings_height_iter_start++;
					continue;
					}
				next_value_check = 0;
				len_string_height_m1 = len_string_height - 1;
				for (i = 1; i <= len_string_height && !stop_now; ++i) {
					next_value_check += (index_multiplier_width + 1);
					for (j = 1; j <= len_string_width; ++j) {
						fake_matrix[i * index_multiplier_width + j] = std::min(std::min(fake_matrix[(i - 1) * index_multiplier_width + j] + 1, fake_matrix[i * index_multiplier_width + (j - 1)] + 1), fake_matrix[(i - 1) * index_multiplier_width + j - 1] + (((current_string_height)[len_string_height_m1 - i + 1] == (current_string_width)[len_string_width_m1 - j + 1]) ? 0 : 1));
						if (i * index_multiplier_width + j != next_value_check) {
							continue;
							}
						if (fake_matrix[i * index_multiplier_width + j] + 1 + current_levenshtein_distance > leven_best_match) {
							stop_now = true;
							break;
							}
						}
					}
				if (stop_now) {
					strings_height_iter_start++;
					continue;
					}
				current_levenshtein_distance += (fake_matrix[len_string_height * index_multiplier_width + len_string_width]);
				if (((current_levenshtein_distance) < leven_best_match) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0)))) {
					leven_best_match = current_levenshtein_distance;
					leven_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				if ((leven_best_match == 2) && (last_string_len_difference == -1)) {
					break;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[leven_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = (float)leven_best_match;
			strings_width_iter_start++;
			}
		}
	static constexpr void calculate_damerau_levenshtein_distance_1_way(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		const int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int leven_best_idx_height;
		int leven_best_match;
		int len_string_width;
		int len_string_height;
		int last_string_len_difference;
		int current_levenshtein_distance;
		int i;
		int j;
		int current_row;
		int prev_row;
		int prevprev_row;
		int weight;
		std::string_view current_string_width;
		std::string_view current_string_height;
		idx_counter_string_width = -1;
		strings_width_iter_start = a_strings;
		std::array<int, 3> startarray = { 0, index_multiplier_width + 1, index_multiplier_width + 1 + index_multiplier_width + 1 };
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			leven_best_idx_height = 0;
			leven_best_match = MAX_32BIT_INT;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height) || (abs(len_string_width - len_string_height) > leven_best_match)) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if (len_string_width == len_string_height && current_string_height[0] == current_string_width[0] && (current_string_width == (current_string_height))) {
					leven_best_idx_height = idx_counter_string_height;
					leven_best_match = 0;
					break;
					}
				i = 0;
				j = 0;
				current_row = 0;
				prev_row = 0;
				prevprev_row = 0;
				weight = 0;
				for (i = 0; i <= len_string_height; i++) {
					fake_matrix[startarray[0] + i] = i;
					fake_matrix[startarray[1] + i] = i;
					fake_matrix[startarray[2] + i] = i;
					}
				for (i = 1; i <= len_string_width; i++) {
					if (i == 1) {
						current_row = startarray[1];
						prev_row = startarray[0];
						prevprev_row = startarray[2];
						}
					else {
						current_row = startarray[i % 3];
						prev_row = startarray[(i - 1) % 3];
						prevprev_row = startarray[(i - 2) % 3];
						}
					fake_matrix[current_row] = i;
					for (j = 1; j <= len_string_height; j++) {
						weight = fake_matrix[prev_row + j - 1] + (current_string_width[i - 1] == current_string_height[j - 1] ? 0 : 1);
						if (weight > fake_matrix[prev_row + j] + 1) {
							weight = fake_matrix[prev_row + j] + 1;
							}
						if (weight > fake_matrix[current_row + j - 1] + 1) {
							weight = fake_matrix[current_row + j - 1] + 1;
							}
						if ((i > 2 && j > 2 && current_string_width[i - 1] == current_string_height[j - 2] && current_string_width[i - 2] == current_string_height[j - 1]) && (weight > fake_matrix[prevprev_row + j - 2])) {
							weight = fake_matrix[prevprev_row + j - 2] + (current_string_width[i - 1] == current_string_height[j - 1] ? 0 : 1);
							}
						fake_matrix[current_row + j] = weight;
						}
					}
				current_levenshtein_distance = fake_matrix[current_row + len_string_height];
				if (((current_levenshtein_distance) < leven_best_match) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0)))) {
					leven_best_match = current_levenshtein_distance;
					leven_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				if ((leven_best_match == 1) && (last_string_len_difference == -1)) {
					break;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[leven_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = (float)leven_best_match;
			strings_width_iter_start++;
			}
		}
	static constexpr void calculate_damerau_levenshtein_distance_2_ways(
		const std::vector<std::string_view>::iterator& a_strings,
		const std::vector<std::string_view>::iterator& b_strings,
		const std::vector<std::string_view>::iterator& a_strings_end,
		const std::vector<std::string_view>::iterator& b_strings_end,
		std::unordered_map<int, std::pair<int, float>>& result_map,
		int* fake_matrix,
		const int index_multiplier_width,
		std::unordered_map<int, int>& vec1_mapping,
		std::unordered_map<int, int>& vec2_mapping
	) {
		std::vector< std::string_view>::iterator strings_width_iter_start = a_strings;
		std::vector< std::string_view>::iterator strings_height_iter_start = b_strings;
		std::vector< std::string_view>::iterator strings_width_iter_end = a_strings_end;
		std::vector< std::string_view>::iterator strings_height_iter_end = b_strings_end;
		int idx_counter_string_width;
		int idx_counter_string_height;
		int leven_best_idx_height;
		int leven_best_match;
		int len_string_width;
		int len_string_height;
		int last_string_len_difference;
		int current_levenshtein_distance;
		int i;
		int j;
		int current_row;
		int prev_row;
		int prevprev_row;
		int weight;
		int len_string_height_m1;
		int len_string_width_m1;
		std::string_view current_string_width;
		std::string_view current_string_height;
		idx_counter_string_width = -1;
		strings_width_iter_start = a_strings;
		std::array<int, 3> startarray = { 0, index_multiplier_width + 1, index_multiplier_width + 1 + index_multiplier_width + 1 };
		while (strings_width_iter_start != strings_width_iter_end) {
			idx_counter_string_width++;
			len_string_width = (int)strings_width_iter_start->size();
			if (!len_string_width) {
				strings_width_iter_start++;
				continue;
				}
			leven_best_idx_height = 0;
			leven_best_match = MAX_32BIT_INT;
			strings_height_iter_start = b_strings;
			current_string_width = *strings_width_iter_start;
			idx_counter_string_height = -1;
			last_string_len_difference = MAX_32BIT_INT;
			len_string_width_m1 = len_string_width - 1;
			while (strings_height_iter_start != strings_height_iter_end) {
				idx_counter_string_height++;
				len_string_height = (int)strings_height_iter_start->size();
				if ((!len_string_height) || (abs(len_string_width - len_string_height) > leven_best_match)) {
					strings_height_iter_start++;
					continue;
					}
				current_string_height = *strings_height_iter_start;
				if (len_string_width == len_string_height && current_string_height[0] == current_string_width[0] && (current_string_width == (current_string_height))) {
					leven_best_idx_height = idx_counter_string_height;
					leven_best_match = 0;
					break;
					}
				len_string_height_m1 = len_string_height - 1;
				i = 0;
				j = 0;
				current_row = 0;
				prev_row = 0;
				prevprev_row = 0;
				weight = 0;
				current_levenshtein_distance = 0;
				for (i = 0; i <= len_string_height; i++) {
					fake_matrix[startarray[0] + i] = i;
					fake_matrix[startarray[1] + i] = i;
					fake_matrix[startarray[2] + i] = i;
					}
				for (i = 1; i <= len_string_width; i++) {
					if (i == 1) {
						current_row = startarray[1];
						prev_row = startarray[0];
						prevprev_row = startarray[2];
						}
					else {
						current_row = startarray[i % 3];
						prev_row = startarray[(i - 1) % 3];
						prevprev_row = startarray[(i - 2) % 3];
						}
					fake_matrix[current_row] = i;
					for (j = 1; j <= len_string_height; j++) {
						weight = fake_matrix[prev_row + j - 1] + (current_string_width[len_string_width_m1 - i + 1] == current_string_height[len_string_height_m1 - j + 1] ? 0 : 1);
						if (weight > fake_matrix[prev_row + j] + 1) {
							weight = fake_matrix[prev_row + j] + 1;
							}
						if (weight > fake_matrix[current_row + j - 1] + 1) {
							weight = fake_matrix[current_row + j - 1] + 1;
							}
						if ((i > 2 && j > 2 && current_string_width[len_string_width_m1 - i + 1] == current_string_height[len_string_height_m1 - j + 2] && current_string_width[len_string_width_m1 - i + 2] == current_string_height[len_string_height_m1 - j + 1]) && (weight > fake_matrix[prevprev_row + j - 2])) {
							weight = fake_matrix[prevprev_row + j - 2] + (current_string_width[len_string_width_m1 - i + 1] == current_string_height[len_string_height_m1 - j + 1] ? 0 : 1);
							}
						fake_matrix[current_row + j] = weight;
						}
					}
				current_levenshtein_distance += fake_matrix[current_row + len_string_height];
				i = 0;
				j = 0;
				current_row = 0;
				prev_row = 0;
				prevprev_row = 0;
				weight = 0;
				for (i = 0; i <= len_string_height; i++) {
					fake_matrix[startarray[0] + i] = i;
					fake_matrix[startarray[1] + i] = i;
					fake_matrix[startarray[2] + i] = i;
					}
				for (i = 1; i <= len_string_width; i++) {
					if (i == 1) {
						current_row = startarray[1];
						prev_row = startarray[0];
						prevprev_row = startarray[2];
						}
					else {
						current_row = startarray[i % 3];
						prev_row = startarray[(i - 1) % 3];
						prevprev_row = startarray[(i - 2) % 3];
						}
					fake_matrix[current_row] = i;
					for (j = 1; j <= len_string_height; j++) {
						weight = fake_matrix[prev_row + j - 1] + (current_string_width[i - 1] == current_string_height[j - 1] ? 0 : 1);
						if (weight > fake_matrix[prev_row + j] + 1) {
							weight = fake_matrix[prev_row + j] + 1;
							}
						if (weight > fake_matrix[current_row + j - 1] + 1) {
							weight = fake_matrix[current_row + j - 1] + 1;
							}
						if ((i > 2 && j > 2 && current_string_width[i - 1] == current_string_height[j - 2] && current_string_width[i - 2] == current_string_height[j - 1]) && (weight > fake_matrix[prevprev_row + j - 2])) {
							weight = fake_matrix[prevprev_row + j - 2] + (current_string_width[i - 1] == current_string_height[j - 1] ? 0 : 1);
							}
						fake_matrix[current_row + j] = weight;
						}
					}
				current_levenshtein_distance += fake_matrix[current_row + len_string_height];
				if (((current_levenshtein_distance) < leven_best_match) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference < len_string_width - len_string_height && last_string_len_difference < 0))) || ((current_levenshtein_distance == leven_best_match) && ((last_string_len_difference > len_string_width - len_string_height && last_string_len_difference > 0 && len_string_width - len_string_height > 0)))) {
					leven_best_match = current_levenshtein_distance;
					leven_best_idx_height = idx_counter_string_height;
					last_string_len_difference = len_string_width - len_string_height;
					}
				if ((leven_best_match == 2) && (last_string_len_difference == -1)) {
					break;
					}
				strings_height_iter_start++;
				}
			result_map[vec1_mapping[idx_counter_string_width]].first = vec2_mapping[leven_best_idx_height];
			result_map[vec1_mapping[idx_counter_string_width]].second = leven_best_match;
			strings_width_iter_start++;
			}
		}
	}

namespace {
	std::string print_padded(int length, char pad, std::string&& inStr) {
		std::string outstrcpp(length, pad);
		if (inStr.empty()) {
			return outstrcpp;
			}
		for (int i = 0; i < length; i++) {
			if (i >= (int)inStr.length()) {
				break;
				}
			outstrcpp[i] = inStr[i];
			}
		return outstrcpp;
		}

	constexpr std::array<uint8_t, 256> ascii_to_lowercase = {
   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,  15,
   16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
   32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
   48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
   64,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
   112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 91,  92,  93,  94,  95,
   96,  97,  98,  99,  100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
   112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
   128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
   144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
   160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
   176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
   192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
   208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
   224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
   240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
		};
	constexpr std::array<uint8_t, 256> ascii_to_uppercase = {
	   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,  15,
	   16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
	   32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
	   48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
	   64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
	   80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
	   96,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
	   80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  123, 124, 125, 126, 127,
	   128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
	   144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
	   160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
	   176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
	   192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
	   208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
	   224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
	   240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
		};
	constexpr std::array<uint8_t, 256> ascii_replace_non_alphanumeric = {
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 32, 32, 32, 32, 32, 32,
   32, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
   80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 32, 32, 32, 32, 32,
   32, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
   112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
		};
	constexpr std::array<uint8_t, 256> ascii_replace_non_printable = {
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
   48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
   64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
   80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
   96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
   112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
   32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
		};
	}
namespace stringhelpers {

	void _repr__for_cython(std::vector<std::string>* v) {
		if (v->size() < 11) {
			for (size_t i = 0; i < v->size(); i++) {
				std::cout << i << ". " << v->at(i) << '\n';
				}
			}
		else {
			for (size_t i = 0; i < 5; i++) {
				std::cout << i << ". " << v->at(i) << '\n';
				}
			std::cout << "..." << '\n';
			for (size_t i = v->size() - 5; i < v->size(); i++) {
				std::cout << i << ". " << v->at(i) << '\n';
				}
			}
		}

	void _repr__for_cython_class(std::vector<std::string_view>& v) {
		if (v.size() < 11) {
			for (size_t i = 0; i < v.size(); i++) {
				std::cout << i << ". " << v[i] << '\n';
				}
			}
		else {
			for (size_t i = 0; i < 5; i++) {
				std::cout << i << ". " << v[i] << '\n';
				}
			std::cout << "..." << '\n';
			for (size_t i = v.size() - 5; i < v.size(); i++) {
				std::cout << i << ". " << v[i] << '\n';
				}
			}
		}

	static int get_max_len_array(const std::vector<std::string_view>& vec) {
		size_t tmp_longest_string_in_width = 0;
		for (size_t i = 0; i < vec.size(); i++) {
			if (tmp_longest_string_in_width < vec[i].size()) {
				tmp_longest_string_in_width = vec[i].size();
				}
			}
		return (int)tmp_longest_string_in_width;
		}

	std::string generate_random_chars(int max_length)
		{
		std::string possible_characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?@#";
		auto possible_characters_size = possible_characters.size();
		std::string ret;
		ret.reserve(max_length);
		for (int i = 0; i < max_length; i++) {
			ret += possible_characters[rand() % possible_characters_size];
			}
		return ret;
		}
	template <typename T>
	std::vector<int> vec_argsort(const std::vector<T>& v) {
		std::vector<int> idx(v.size());
		std::iota(idx.begin(), idx.end(), 0);
		std::stable_sort(idx.begin(), idx.end(), [&v](int i1, int i2) {
			if (v[i1].size() != v[i2].size()) {
				return v[i1].size() > v[i2].size();
				}
			return v[i1] < v[i2];
			}
		);
		return idx;
		}
	template <typename T>
	std::vector<std::string> to_upper(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].resize(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				outvec[j][i] = ascii_to_uppercase[invec[j][i]];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> to_lower(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].resize(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				outvec[j][i] = ascii_to_lowercase[invec[j][i]];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> to_remove_non_alphanumeric(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].resize(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				outvec[j][i] = ascii_replace_non_alphanumeric[invec[j][i]];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> to_remove_non_printable(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].resize(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				outvec[j][i] = ascii_replace_non_printable[invec[j][i]];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> create_copy(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].resize(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				outvec[j][i] = invec[j][i];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> remove_whitepaces(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].reserve(invec[j].size());
			for (size_t i = 0; i < invec[j].size(); i++) {
				if ((invec[j][i] == ' ') || (invec[j][i] == '\t') || (invec[j][i] == '\n') || (invec[j][i] == '\r') || (invec[j][i] == '\v') || (invec[j][i] == '\f')) {
					continue;
					}
				outvec[j] += invec[j][i];
				}
			}
		return outvec;
		}
	template <typename T>
	std::vector<std::string> normalize_whitepaces(const std::vector<T>& invec) {
		std::vector<std::string> outvec;
		outvec.resize(invec.size());
		for (size_t j = 0; j < invec.size(); j++) {
			outvec[j].reserve(invec[j].size());
			int last_whitespace_counter = 1;
			for (size_t i = 0; i < invec[j].size(); i++) {
				if ((last_whitespace_counter == 0) && ((invec[j][i] == ' ') || (invec[j][i] == '\t') || (invec[j][i] == '\n') || (invec[j][i] == '\r') || (invec[j][i] == '\v') || (invec[j][i] == '\f'))) {
					outvec[j] += ' ';
					last_whitespace_counter += 1;
					continue;
					}
				else if ((last_whitespace_counter != 0) && ((invec[j][i] == ' ') || (invec[j][i] == '\t') || (invec[j][i] == '\n') || (invec[j][i] == '\r') || (invec[j][i] == '\v') || (invec[j][i] == '\f'))) {
					last_whitespace_counter += 1;
					continue;
					}
				last_whitespace_counter = 0;
				outvec[j] += invec[j][i];
				}
			if ((!outvec[j].empty()) && (outvec[j].back() == ' ')) {
				outvec[j].resize(outvec[j].size() - 1);
				}
			}
		return outvec;
		}

	void save_as_file(const std::string& filename, const std::string& _str) {
		FILE* pipe = fopen(filename.c_str(), "w");
		if (pipe == NULL) {
			throw std::runtime_error("Could not open file");
			}
		for (size_t i = 0; i < _str.size(); i++) {
			putc(_str[i], pipe);
			}
		fclose(pipe);
		}


	static 	std::vector<std::string>  read_file_to_vector_lines(const char* filename) {
		FILE* pipe = fopen(filename, "rb");
		if (pipe == NULL) {
			throw std::runtime_error("Could not open file");
			}
		char buffer[128];
		memset(buffer, 0, sizeof(buffer));
		int size_my_buffer = sizeof(buffer);
		std::string cpptmpstring;
		cpptmpstring.reserve(1024);
		std::vector<std::string> filelines;
		while (fgets(buffer, size_my_buffer, pipe) != NULL) {
			//try {
			for (int i = 0; i < size_my_buffer; i++) {
				if (buffer[i] == '\0') {
					continue;
					}
				if (buffer[i] == '\n') {
					buffer[i] = '\0';
					if (cpptmpstring.back() == '\r') {
						cpptmpstring.pop_back();
						}
					filelines.push_back(cpptmpstring);
					cpptmpstring.clear();
					}
				else {
					cpptmpstring += (buffer[i]);
					buffer[i] = '\0';
					}
				}
			}
		fclose(pipe);
		return filelines;
		}
	// string from base16
	static 	std::vector<std::string>  read_file_to_vector_lines(const std::string& filename) {
		return read_file_to_vector_lines(filename.c_str());
		}

	static std::string string_from_base16(const std::string_view str) {
		std::string cstring2hex;
		cstring2hex.reserve(str.size() / 2);
		for (size_t i = 0; i < str.size(); i += 2) {
			char result{};
			std::from_chars(str.data() + i, str.data() + i + 2, result, 16);
			cstring2hex += result;
			}
		return cstring2hex;
		}
	static 	std::vector<std::string>  read_base16file_to_vector_lines(const char* filename) {
		auto vec1 = read_file_to_vector_lines(filename);
		for (size_t i = 0; i < vec1.size(); i++) {
			vec1[i] = string_from_base16(vec1[i]);
			}
		return vec1;

		}

	}
class StringMatcher {
public:

	// empty constructor for Cython - don't use!
	//StringMatcher() {
	//	}

	StringMatcher(std::vector<std::string>& v1, std::vector<std::string>& v2)
		: _svvec_a(v1.begin(), v1.end()), _svvec_b(v2.begin(), v2.end()) {
		}
	StringMatcher(const std::vector<std::string_view>& v1, const std::vector<std::string_view>& v2)
		: _svvec_a(v1.begin(), v1.end()), _svvec_b(v2.begin(), v2.end()) {
		}

	explicit StringMatcher(std::vector<std::string>&& v1, std::vector<std::string>&& v2)
		: _svvec_a_for_copyconst(std::move(v1)), _svvec_b_for_copyconst(std::move(v2)), _svvec_a(_svvec_a_for_copyconst.begin(), _svvec_a_for_copyconst.end()), _svvec_b(_svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end()) {
		}

	StringMatcher(const std::string& v1, const std::string& v2)
		: _svvec_a_for_copyconst({ v1 }), _svvec_b_for_copyconst({ v2 }), _svvec_a(_svvec_a_for_copyconst.begin(), _svvec_a_for_copyconst.end()), _svvec_b(_svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end()) {
		}
	StringMatcher(const std::vector<std::string>& v1, const std::string& v2)
		:_svvec_b_for_copyconst({ v2 }), _svvec_a(v1.begin(), v1.end()), _svvec_b(_svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end()) {
		}
	StringMatcher(const std::string& v1, const std::vector<std::string>& v2)
		:_svvec_b_for_copyconst({ v1 }), _svvec_a(v2.begin(), v2.end()), _svvec_b(_svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end()) {
		}
	StringMatcher(const char* v1[], const char* v2[], size_t v1_size, size_t v2_size) {

		_svvec_a_for_copyconst.reserve(v1_size);
		_svvec_b_for_copyconst.reserve(v2_size);
		for (size_t i = 0; i < v1_size; i++) {
			_svvec_a_for_copyconst.emplace_back(v1[i]);
			_svvec_a.emplace_back(_svvec_a_for_copyconst[i]);
			}
		for (size_t i = 0; i < v2_size; i++) {
			_svvec_b_for_copyconst.emplace_back(v2[i]);
			_svvec_b.emplace_back(_svvec_b_for_copyconst[i]);
			}
		}
	//don't use this - Cython only 
	void _load_vecs_for_cython(std::vector<std::string>* v1, std::vector<std::string>* v2) {
		_svvec_a_for_copyconst = { v1->begin(), v1->end() };
		_svvec_b_for_copyconst = { v2->begin(), v2->end() };
		_svvec_a = { _svvec_a_for_copyconst.begin(), _svvec_a_for_copyconst.end() };
		_svvec_b = { _svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end() };
		_check_if_argsorted();
		}

	void _str__for_cython() {
		std::cout << "\n------------------------------Vector 1\n";
		stringhelpers::_repr__for_cython_class(_svvec_a);
		std::cout << "\n------------------------------Vector 2\n";
		stringhelpers::_repr__for_cython_class(_svvec_b);
		std::cout << "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";

		}

private:
	std::vector<std::string> _svvec_a_for_copyconst;
	std::vector<std::string> _svvec_b_for_copyconst;
	std::vector<std::string_view> _svvec_a;
	std::vector<std::string_view> _svvec_b;
	std::vector< std::string_view>::iterator _svvec_a_begin;
	std::vector< std::string_view>::iterator _svvec_a_end;
	std::vector< std::string_view>::iterator _svvec_b_begin;
	std::vector< std::string_view>::iterator _svvec_b_end;
	std::unordered_map<int, std::pair<int, float>> _results;
	std::unordered_map<int, int>   _vec1_mapping_1;
	std::unordered_map<int, int>   _vec2_mapping_1;
	std::unordered_map<int, int>   _vec1_mapping_2;
	std::unordered_map<int, int>   _vec2_mapping_2;
	int _max_len_a = 0;
	int _max_len_b = 0;



	void _update_string_data() {
		_svvec_a = { _svvec_a_for_copyconst.begin(), _svvec_a_for_copyconst.end() };
		_svvec_b = { _svvec_b_for_copyconst.begin(), _svvec_b_for_copyconst.end() };
		_check_if_argsorted();
		}
	void _check_if_argsorted() {
		_max_len_a = 0;
		_max_len_b = 0;
		auto argvec1 = stringhelpers::vec_argsort(_svvec_a);
		auto argvec2 = stringhelpers::vec_argsort(_svvec_b);
		_vec1_mapping_1.reserve(_svvec_a.size());
		_vec1_mapping_2.reserve(_svvec_a.size());
		_vec2_mapping_1.reserve(_svvec_b.size());
		_vec2_mapping_2.reserve(_svvec_b.size());
		std::vector< std::string_view> vec1_string_views;
		std::vector< std::string_view> vec2_string_views;
		vec1_string_views.reserve(_svvec_a.size());
		vec2_string_views.reserve(_svvec_b.size());
		for (size_t i = 0; i < _svvec_a.size(); i++)
			{
			_vec1_mapping_1[argvec1[i]] = i;
			_vec1_mapping_2[i] = argvec1[i];
			vec1_string_views.emplace_back(_svvec_a[argvec1[i]]);
			if (vec1_string_views[i].size() > (size_t)_max_len_a) { _max_len_a = (int)vec1_string_views[i].size(); }
			}
		for (size_t i = 0; i < _svvec_b.size(); i++)
			{
			_vec2_mapping_1[argvec2[i]] = i;
			_vec2_mapping_2[i] = argvec2[i];
			vec2_string_views.emplace_back(_svvec_b[argvec2[i]]);
			if (vec2_string_views[i].size() > (size_t)_max_len_b) { _max_len_b = (int)vec2_string_views[i].size(); }
			}
		_svvec_a = std::move(vec1_string_views);
		_svvec_b = std::move(vec2_string_views);
		_svvec_a_begin = _svvec_a.begin();
		_svvec_a_end = _svvec_a.end();
		_svvec_b_begin = _svvec_b.begin();
		_svvec_b_end = _svvec_b.end();
		}
	int* _create_levenshtein_fake_matrix(int tmp_longest_string_in_width,
		int tmp_longest_string_in_height) {
		auto fake_matrix = new(std::nothrow) int[(tmp_longest_string_in_width + 1) * (tmp_longest_string_in_height + 1)];
		if (!fake_matrix) {
			throw std::bad_alloc();
			}
		for (int idx_height = 0; idx_height < tmp_longest_string_in_height; idx_height++) {
			fake_matrix[idx_height * tmp_longest_string_in_width] = idx_height;
			}
		for (int idx_width = 0; idx_width < tmp_longest_string_in_width; idx_width++) {
			fake_matrix[idx_width] = idx_width;
			}
		return fake_matrix;
		}
	int* _create_jaro_fake_matrix() {
		auto fake_matrix = new(std::nothrow) int[std::max(_max_len_a, _max_len_b) * 2];
		if (!fake_matrix) {
			throw std::bad_alloc();
			}
		return fake_matrix;
		}

	int* _create_subseqv1_fake_matrix() {
		auto fake_matrix = new(std::nothrow) int[(std::max(_max_len_a, _max_len_b) + 1) * 2];
		if (!fake_matrix) {
			throw std::bad_alloc();
			}
		return fake_matrix;
		}


	void _fill_result_map(const int n) {
		_results.clear();
		if (_vec1_mapping_1.empty()) {
			_check_if_argsorted();
			}
		for (int map_creator = 0; map_creator < n; map_creator++) {
			_results.emplace(map_creator, std::pair<int, float>(0, strsearch::MAX_32BIT_INT));
			}
		}

	std::string _convert_ab_to_csv() {
		std::string csv_output;
		csv_output.reserve(std::max(_max_len_a, _max_len_b) * _results.size());
		for (const auto& indexa_indexb_percent : _results) {
			try {
				csv_output += "\"";
				csv_output += std::to_string(indexa_indexb_percent.first);
				csv_output += "\",\"";
				csv_output += std::to_string(indexa_indexb_percent.second.first);
				csv_output += "\",\"";
				csv_output += std::string(_svvec_a.at(_vec1_mapping_1.at(indexa_indexb_percent.first)));
				csv_output += "\",\"";
				csv_output += std::string(_svvec_b.at(_vec2_mapping_1.at(indexa_indexb_percent.second.first)));
				csv_output += "\",\"";
				csv_output += std::to_string(fabs(indexa_indexb_percent.second.second));
				csv_output += "\",\"";
				csv_output += ((indexa_indexb_percent.second.second < 0) ? "1" : "0");
				csv_output += "\"\n";
				}
			catch (const std::exception& e) {
				std::cout << e.what() << std::endl;
				}
			}
		return csv_output;
		}

	auto _do_afterjobs_ab(
		bool print_table = false,
		bool print_csv = false,
		const std::string& file_path = "",
		int _convert_rule = 0

	) {
		std::unordered_map<int64_t, std::unordered_map<int64_t, std::pair<double, int64_t>>> new_map;
		new_map.reserve(_results.size());
		for (const auto& it : _results) {
			//std::cout << (it.second.second) << std::endl;
			if (_convert_rule == 0) {
				int64_t was_switched = 0;
				if (it.second.second < 0) {
					was_switched = 1;
					}
				std::pair<double, int64_t> my_pair = std::make_pair(fabs(it.second.second), was_switched);
				new_map.emplace(it.first, std::unordered_map<int64_t, std::pair<double, int64_t>>{ {it.second.first, my_pair }});
				}
			}
		if (print_table) {
			_print_neg_percentage(true);
			}
		if ((print_csv) || (!file_path.empty())) {

			auto csv_output = _convert_ab_to_csv();
			if (!file_path.empty()) {
				stringhelpers::save_as_file(file_path, csv_output);
				}
			if (print_csv) {
				std::cout << csv_output << std::endl;
				}
			}
		return new_map;
		}

	std::string _convert_ba_to_csv() {
		std::string csv_output;
		csv_output.reserve(std::max(_max_len_a, _max_len_b) * _results.size());
		for (const auto& indexa_indexb_percent : _results) {
			try {
				csv_output += "\"";
				csv_output += std::to_string(indexa_indexb_percent.first);
				csv_output += "\",\"";
				csv_output += std::to_string(indexa_indexb_percent.second.first);
				csv_output += "\",\"";
				csv_output += std::string(_svvec_b.at(_vec2_mapping_1.at(indexa_indexb_percent.first)));
				csv_output += "\",\"";
				csv_output += std::string(_svvec_a.at(_vec1_mapping_1.at(indexa_indexb_percent.second.first)));
				csv_output += "\",\"";
				csv_output += std::to_string(fabs(indexa_indexb_percent.second.second));
				csv_output += "\",\"";
				csv_output += ((indexa_indexb_percent.second.second < 0) ? "1" : "0");
				csv_output += "\"\n";
				}
			catch (const std::exception& e) {
				std::cout << e.what() << std::endl;
				}
			}
		return csv_output;
		}

	auto _do_afterjobs_ba(
		bool print_table = false,
		bool print_csv = false,
		const std::string& file_path = "",
		int _convert_rule = 0

	) {
		std::unordered_map<int64_t, std::unordered_map<int64_t, std::pair<double, int64_t>>> new_map;
		new_map.reserve(_results.size());
		for (const auto& it : _results) {
			if (_convert_rule == 0) {
				int64_t was_switched = 0;
				if (it.second.second < 0) {
					was_switched = 1;
					}
				std::pair<double, int64_t> my_pair = std::make_pair(fabs(it.second.second), was_switched);

				new_map.emplace(it.first, std::unordered_map<int64_t, std::pair<double, int64_t>>{ {it.second.first, my_pair }});
				}
			}
		if (print_table) {
			_print_neg_percentage(false);
			}
		if ((print_csv) || (!file_path.empty())) {
			auto csv_output = _convert_ba_to_csv();
			if (!file_path.empty()) {
				stringhelpers::save_as_file(file_path, csv_output);
				}
			if (print_csv) {
				std::cout << csv_output << std::endl;
				}
			}
		return new_map;
		}

	void _print_neg_percentage(bool printab = true) {
		//#ifdef BUILD_LIB

		if (!printab) {
			return _print_ba_results();
			}
		std::vector < std::pair<int, std::pair<int, float>> > sorted_elements;
		sorted_elements = { _results.begin(), _results.end() };
		std::cout << "---------------------------------------------------------------------------------------------------------------------------------------------------------------" << std::endl;
		std::cout << print_padded(10, ' ', "index_v1");
		std::cout << " | ";
		std::cout << print_padded(10, ' ', "index_v2");
		std::cout << " | ";
		std::cout << print_padded(35, ' ', "string_v1");
		std::cout << " | ";
		std::cout << print_padded(35, ' ', "string_v2");
		std::cout << " | ";
		std::cout << print_padded(20, ' ', "value");
		std::cout << " | ";
		std::cout << print_padded(20, ' ', "v1_is_substring");
		std::cout << " | " << std::endl;
		std::cout << "---------------------------------------------------------------------------------------------------------------------------------------------------------------" << std::endl;
		for (const auto& indexa_indexb_percent : sorted_elements) {
			try {
				std::cout << print_padded(10, ' ', std::to_string(indexa_indexb_percent.first));
				std::cout << " | ";
				std::cout << print_padded(10, ' ', std::to_string(indexa_indexb_percent.second.first));
				std::cout << " | ";
				std::cout << print_padded(35, ' ', std::string(_svvec_a.at(_vec1_mapping_1.at(indexa_indexb_percent.first))));
				std::cout << " | ";
				std::cout << print_padded(35, ' ', std::string(_svvec_b.at(_vec2_mapping_1.at(indexa_indexb_percent.second.first))));
				std::cout << " | ";
				std::cout << print_padded(20, ' ', std::to_string(fabs(indexa_indexb_percent.second.second)));
				std::cout << " | ";
				std::cout << print_padded(20, ' ', (indexa_indexb_percent.second.second < 0) ? "true" : "false");
				std::cout << " | " << std::endl;
				}
			catch (const std::exception& e) {
				std::cout << e.what() << std::endl;
				}
			}
		//#else
		//#endif

		}
	void _print_ba_results() {
		//#ifdef BUILD_LIB

		std::vector < std::pair<int, std::pair<int, float>> > sorted_elements;
		sorted_elements = { _results.begin(), _results.end() };
		std::cout << "---------------------------------------------------------------------------------------------------------------------------------------------------------------" << std::endl;
		std::cout << print_padded(10, ' ', "index_v1");
		std::cout << " | ";
		std::cout << print_padded(10, ' ', "index_v2");
		std::cout << " | ";
		std::cout << print_padded(35, ' ', "string_v1");
		std::cout << " | ";
		std::cout << print_padded(35, ' ', "string_v2");
		std::cout << " | ";
		std::cout << print_padded(20, ' ', "value");
		std::cout << " | ";
		std::cout << print_padded(20, ' ', "v1_is_substring");
		std::cout << " | " << std::endl;
		std::cout << "---------------------------------------------------------------------------------------------------------------------------------------------------------------" << std::endl;
		for (const auto& indexa_indexb_percent : sorted_elements) {
			try {
				std::cout << print_padded(10, ' ', std::to_string(indexa_indexb_percent.first));
				std::cout << " | ";
				std::cout << print_padded(10, ' ', std::to_string(indexa_indexb_percent.second.first));
				std::cout << " | ";
				std::cout << print_padded(35, ' ', std::string(_svvec_b.at(_vec2_mapping_1.at(indexa_indexb_percent.first))));
				std::cout << " | ";
				std::cout << print_padded(35, ' ', std::string(_svvec_a.at(_vec1_mapping_1.at(indexa_indexb_percent.second.first))));
				std::cout << " | ";
				std::cout << print_padded(20, ' ', std::to_string(fabs(indexa_indexb_percent.second.second)));
				std::cout << " | ";
				std::cout << print_padded(20, ' ', (indexa_indexb_percent.second.second < 0) ? "true" : "false");
				std::cout << " | " << std::endl;
				}
			catch (const std::exception& e) {
				std::cout << e.what() << std::endl;
				}
			}
		//#else
		//#endif
		}


public:


	StringMatcher& to_upper() {
		_svvec_a_for_copyconst = stringhelpers::to_upper(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::to_upper(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_lower() {
		_svvec_a_for_copyconst = stringhelpers::to_lower(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::to_lower(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_without_non_alphanumeric() {
		_svvec_a_for_copyconst = stringhelpers::to_remove_non_alphanumeric(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::to_remove_non_alphanumeric(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_without_non_printable() {
		_svvec_a_for_copyconst = stringhelpers::to_remove_non_printable(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::to_remove_non_printable(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_100_percent_copy() {
		_svvec_a_for_copyconst = stringhelpers::create_copy(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::create_copy(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_without_whitespaces() {
		_svvec_a_for_copyconst = stringhelpers::remove_whitepaces(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::remove_whitepaces(_svvec_b);
		_update_string_data();
		return *this;
		}
	StringMatcher& to_with_normalized_whitespaces() {
		_svvec_a_for_copyconst = stringhelpers::normalize_whitepaces(_svvec_a);
		_svvec_b_for_copyconst = stringhelpers::normalize_whitepaces(_svvec_b);
		_update_string_data();
		return *this;
		}

	auto ab_map_longest_common_substring_v1(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		strsearch::calculate_longest_common_substr_v1(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, _vec1_mapping_2, _vec2_mapping_2);
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_longest_common_substring_v1(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		strsearch::calculate_longest_common_substr_v1(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, _vec2_mapping_2, _vec1_mapping_2);
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}

	auto ab_map_hemming_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		strsearch::calculate_hemming_distance_1way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, _vec1_mapping_2, _vec2_mapping_2);
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_hemming_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		strsearch::calculate_hemming_distance_1way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, _vec2_mapping_2, _vec1_mapping_2);
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}


	auto ab_map_hemming_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		strsearch::calculate_hemming_distance_2ways(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, _vec1_mapping_2, _vec2_mapping_2);
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_hemming_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		strsearch::calculate_hemming_distance_2ways(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, _vec2_mapping_2, _vec1_mapping_2);
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}


	auto ab_map_longest_common_substring_v0(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		strsearch::calculate_longest_common_substring(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, true, _vec1_mapping_2, _vec2_mapping_2);
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}


	auto ba_map_longest_common_substring_v0(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		strsearch::calculate_longest_common_substring(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, true, _vec2_mapping_2, _vec1_mapping_2);
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_longest_common_subsequence_v0(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		strsearch::calculate_longest_common_substring(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, false, _vec1_mapping_2, _vec2_mapping_2);
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_longest_common_subsequence_v0(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		strsearch::calculate_longest_common_substring(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, false, _vec2_mapping_2, _vec1_mapping_2);
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_damerau_levenshtein_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_a, _max_len_b);
		strsearch::calculate_damerau_levenshtein_distance_2_ways(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, _max_len_a, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_damerau_levenshtein_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_b, _max_len_a);
		strsearch::calculate_damerau_levenshtein_distance_2_ways(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, _max_len_b, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_damerau_levenshtein_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_a, _max_len_b);
		strsearch::calculate_damerau_levenshtein_distance_1_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, _max_len_a, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_damerau_levenshtein_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_b, _max_len_a);
		strsearch::calculate_damerau_levenshtein_distance_1_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, _max_len_b, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_levenshtein_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_a, _max_len_b);
		strsearch::calculate_levenshtein_distance_1_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, _max_len_a, _vec1_mapping_2, _vec2_mapping_2);

		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_levenshtein_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_b, _max_len_a);
		strsearch::calculate_levenshtein_distance_1_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, _max_len_b, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_levenshtein_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_a, _max_len_b);
		strsearch::calculate_levenshtein_distance_2_ways(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, _max_len_a, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);

		}
	auto ba_map_levenshtein_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		auto fake_matrix = _create_levenshtein_fake_matrix(_max_len_b, _max_len_a);
		strsearch::calculate_levenshtein_distance_2_ways(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, _max_len_b, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_jaro_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_distance_1_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_jaro_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_distance_1_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_jaro_winkler_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_winkler_distance_1_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_jaro_winkler_distance_1way(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_winkler_distance_1_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_jaro_winkler_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_winkler_distance_2_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_jaro_winkler_distance_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_winkler_distance_2_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}
	auto ab_map_jaro_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_distance_2_way(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_jaro_2ways(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_jaro_distance_2_way(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}


	auto ab_map_subsequence_v1(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_subseqv1_fake_matrix();
		strsearch::calculate_longest_common_subsequence_v1(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_subsequence_v1(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_subseqv1_fake_matrix();
		strsearch::calculate_longest_common_subsequence_v1(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}

	auto ab_map_subsequence_v2(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_a);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_longest_common_subsequence_v2(_svvec_a_begin, _svvec_b_begin, _svvec_a_end, _svvec_b_end, _results, fake_matrix, max_width, _vec1_mapping_2, _vec2_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ab(print_results, convert_to_csv, file_path, 0);
		}
	auto ba_map_subsequence_v2(
		bool print_results = false,
		bool convert_to_csv = false,
		std::string file_path = ""
	) {
		_fill_result_map(_max_len_b);
		int max_width = std::max(_max_len_a, _max_len_b);
		auto fake_matrix = _create_jaro_fake_matrix();
		strsearch::calculate_longest_common_subsequence_v2(_svvec_b_begin, _svvec_a_begin, _svvec_b_end, _svvec_a_end, _results, fake_matrix, max_width, _vec2_mapping_2, _vec1_mapping_2);
		delete[] fake_matrix;
		return _do_afterjobs_ba(print_results, convert_to_csv, file_path, 0);
		}

	};

#endif /* FUZZMATCHER_HPP */