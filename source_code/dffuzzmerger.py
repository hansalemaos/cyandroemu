import pandas as pd
from pandas.core.frame import DataFrame, Series, Index
from .dffuzzmerge import *
from contextlib import suppress as contextlib_suppress


def get_name_not_in_cols(columns1, columns2):
    idxtmp1 = "___IDXTMP{number2replace}___"
    idxtmp2 = "___IDXTMP{number2replace}___"
    startnumber_1 = 0
    startnumber_2 = 1
    newcol1 = idxtmp1.format(number2replace=startnumber_1)
    newcol2 = idxtmp2.format(number2replace=startnumber_2)
    while newcol1 in columns1:
        startnumber_1 += 2
        newcol1 = idxtmp1.format(number2replace=startnumber_1)
    while newcol2 in columns2:
        startnumber_2 += 2
        newcol2 = idxtmp2.format(number2replace=startnumber_2)
    return newcol1, newcol2


def fuzzmatch(
    df1,
    df2,
    left_on,
    right_on,
    result_column="aa_match",
    idx_column2="fuzzidx2",
    function="ab_map_damerau_levenshtein_distance_2ways",
):
    if not isinstance(df2, DataFrame):
        df2 = pd.DataFrame(df2, columns=[right_on])
    df11 = df1.copy()
    df22 = df2.copy()
    df1 = (
        df1.loc[(df1[left_on].str.strip() != "")]
        .dropna(subset=[left_on])
        .drop_duplicates(subset=[left_on])
        .reset_index(drop=True)
        .copy()
    )
    df2 = (
        df2.loc[(df2[right_on].str.strip() != "")]
        .dropna(subset=[right_on])
        .drop_duplicates(subset=[right_on])
        .reset_index(drop=True)
        .copy()
    )
    idxtmp1, idxtmp2 = get_name_not_in_cols(df1.columns, df2.columns)
    pysm = PyStringMatcher(
        df1[left_on],
        df2[right_on],
    )
    q = getattr(pysm, function)()
    maplist1 = []
    maplist2 = []
    matchlist = []
    # print(df1)
    # print(df2)
    for x in q.values():
        with contextlib_suppress(Exception):
            realstring1 = df1.loc[x["aa_index_1"], left_on]
            realstring2 = df2.loc[x["aa_index_2"], right_on]
            result1 = df11.loc[df11[left_on] == realstring1].index
            result2 = df22.loc[df22[right_on] == realstring2].index[0]
            maplist1.extend(result1)
            maplist2.extend([result2 for _ in range(len(result1))])
            matchlist.extend((x["aa_match"] for _ in range(len(result1))))

    finalresult1 = (
        df11.loc[maplist1].assign(**{idxtmp1: maplist1}).reset_index(drop=True)
    )
    finalresult2 = (
        df22.loc[maplist2]
        .assign(**{idxtmp2: maplist2, result_column: matchlist})
        .reset_index(drop=True)
    )
    dffinal = pd.concat([finalresult1, finalresult2], axis=1)
    dffinal.index = dffinal[idxtmp1].__array__().copy()
    dffinal.drop(idxtmp1, axis=1, inplace=True)
    notfound = sorted(set(df11.index) - set(maplist1))
    dffinal2 = pd.concat([dffinal, df11.loc[notfound]], axis=0).loc[df11.index]
    dffinal2[idxtmp2] = dffinal2[idxtmp2].astype("Int64")
    return dffinal2.rename(columns={idxtmp2: idx_column2})


def d_fm_damerau_levenshtein_distance_1way(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="damerau_levenshtein_distance_1way_match",
        idx_column2="damerau_levenshtein_distance_1way_idx",
        function="ab_map_damerau_levenshtein_distance_1way",
    )


def d_fm_damerau_levenshtein_distance_2ways(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="damerau_levenshtein_distance_2ways_match",
        idx_column2="damerau_levenshtein_distance_2ways_idx",
        function="ab_map_damerau_levenshtein_distance_2ways",
    )


def d_fm_hemming_distance_1way(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="hemming_distance_1way_match",
        idx_column2="hemming_distance_1way_idx",
        function="ab_map_hemming_distance_1way",
    )


def d_fm_hemming_distance_2ways(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="hemming_distance_2ways_match",
        idx_column2="hemming_distance_2ways_idx",
        function="ab_map_hemming_distance_2ways",
    )


def d_fm_jaro_2ways(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="jaro_2ways_match",
        idx_column2="jaro_2ways_idx",
        function="ab_map_jaro_2ways",
    )


def d_fm_jaro_distance_1way(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="jaro_distance_1way_match",
        idx_column2="jaro_distance_1way_idx",
        function="ab_map_jaro_distance_1way",
    )


def d_fm_jaro_winkler_distance_1way(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="jaro_winkler_distance_1way_match",
        idx_column2="jaro_winkler_distance_1way_idx",
        function="ab_map_jaro_winkler_distance_1way",
    )


def d_fm_jaro_winkler_distance_2ways(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="jaro_winkler_distance_2ways_match",
        idx_column2="jaro_winkler_distance_2ways_idx",
        function="ab_map_jaro_winkler_distance_2ways",
    )


def d_fm_levenshtein_distance_1way(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="levenshtein_distance_1way_match",
        idx_column2="levenshtein_distance_1way_idx",
        function="ab_map_levenshtein_distance_1way",
    )


def d_fm_levenshtein_distance_2ways(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="levenshtein_distance_2ways_match",
        idx_column2="levenshtein_distance_2ways_idx",
        function="ab_map_levenshtein_distance_2ways",
    )


def d_fm_longest_common_subsequence_v0(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="longest_common_subsequence_v0_match",
        idx_column2="longest_common_subsequence_v0_idx",
        function="ab_map_longest_common_subsequence_v0",
    )


def d_fm_longest_common_substring_v0(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="longest_common_substring_v0_match",
        idx_column2="longest_common_substring_v0_idx",
        function="ab_map_longest_common_substring_v0",
    )


def d_fm_longest_common_substring_v1(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="longest_common_substring_v1_match",
        idx_column2="longest_common_substring_v1_idx",
        function="ab_map_longest_common_substring_v1",
    )


def d_fm_subsequence_v1(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="subsequence_v1_match",
        idx_column2="subsequence_v1_idx",
        function="ab_map_subsequence_v1",
    )


def d_fm_subsequence_v2(
    self,
    df2,
    left_on,
    right_on,
):
    return fuzzmatch(
        df1=self,
        df2=df2,
        left_on=left_on,
        right_on=right_on,
        result_column="subsequence_v2_match",
        idx_column2="subsequence_v2_idx",
        function="ab_map_subsequence_v2",
    )


DataFrame.d_fm_damerau_levenshtein_distance_1way = (
    d_fm_damerau_levenshtein_distance_1way
)
DataFrame.d_fm_damerau_levenshtein_distance_2ways = (
    d_fm_damerau_levenshtein_distance_2ways
)
DataFrame.d_fm_hemming_distance_1way = d_fm_hemming_distance_1way
DataFrame.d_fm_hemming_distance_2ways = d_fm_hemming_distance_2ways
DataFrame.d_fm_jaro_2ways = d_fm_jaro_2ways
DataFrame.d_fm_jaro_distance_1way = d_fm_jaro_distance_1way
DataFrame.d_fm_jaro_winkler_distance_1way = d_fm_jaro_winkler_distance_1way
DataFrame.d_fm_jaro_winkler_distance_2ways = d_fm_jaro_winkler_distance_2ways
DataFrame.d_fm_levenshtein_distance_1way = d_fm_levenshtein_distance_1way
DataFrame.d_fm_levenshtein_distance_2ways = d_fm_levenshtein_distance_2ways
DataFrame.d_fm_longest_common_subsequence_v0 = d_fm_longest_common_subsequence_v0
DataFrame.d_fm_longest_common_substring_v0 = d_fm_longest_common_substring_v0
DataFrame.d_fm_longest_common_substring_v1 = d_fm_longest_common_substring_v1
DataFrame.d_fm_subsequence_v1 = d_fm_subsequence_v1
DataFrame.d_fm_subsequence_v2 = d_fm_subsequence_v2
