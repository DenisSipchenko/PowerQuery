/* Alternate version of built-in Table.Profile version.
   Differently treat nulls and mixed data types in columns.

   For example:
       Source = Table.FromList({""abc"", 1, 2, null, 3, ""zyx""}, Splitter.SplitByNothing())

   The difference in results is:
                              | Column  | Min  | Max  | Median | Average | StdDev | Sum | Count | NullCount | DistinctCount  | MinValue | MaxValue  | MedianValue |
                              |---------|------|------|--------|---------|--------|-----|-------|-----------|----------------|----------|-----------|-------------|
      Table.Profile(Source):  | Column1 | null | null |        | null    | null   |     | 6     | 1         | null           |          |           |             |
    fnTable_Profile(Source):  | Column1 | 1    | 3    | 2      | 2       | 1      | 6   | 6     | 1         | 6              | 1        | zyx       | 3           |

History:
    2025-02-18 | Denis Sipchenko | initial
*/
let
    fn=(inputTable as table) as table =>
    let
        Source  = inputTable, // For debugging purposes (transform function to query by commenting 1st line)
        columns = Table.ColumnNames(Source),
        profile = List.Transform(columns, each 
            let
            // List Variables required for profile aggregations
                columnData  = Table.Column(Source, _),
                numericData = List.RemoveNulls(List.Transform(columnData, each try Number.From(_) otherwise null)), // columnData with numeric values only
            // Scalar variables
                count = List.Count(columnData)
            in
                [            
                    Column         = _ ,
                // NUMERIC TYPE aggregations    
                    Min            = List.Min(                numericData),
                    Max            = List.Max(                numericData),
                    Median         = List.Median(             numericData),
                    Average        = List.Average(            numericData),
                    StdDev         = List.StandardDeviation(  numericData),
                    Sum            = List.Sum(                numericData),
                // GENERIC TYPE aggregations
                    Count          = count                                ,
                    NullCount      = count-List.NonNullCount( columnData ), 
                    DistinctCount  = List.Count(List.Distinct(columnData)),
                    MinValue       = List.Min(                columnData ),                    
                    MaxValue       = List.Max(                columnData ),
                    MedianValue    = List.Median(             columnData )
                ]
        ),
        result = Table.FromRecords(profile)
    in
        result
in 
    // Add Description
    Value.ReplaceType(fn, Value.Type(fn) meta
        [
            Documentation.Name = "fnTable_Profile", 
            Documentation.LongDescription = "Alternate version of built-in Table.Profile version. Differently treat nulls and mixed data types in columns",
            Documentation.Examples = {
                [
                    Description = "Functions Table.Profile and fnTable_Profile returning totaly different results for the following data:", 
                    Code        = "    Source = Table.FromList({""abc"", 1, 2, null, 3, ""zyx""}, Splitter.SplitByNothing())",
                    Result      = " 
                              | Column  | Min  | Max  | Median | Average | StdDev | Sum | Count | NullCount | DistinctCount  | MinValue | MaxValue  | MedianValue |
                              |---------|------|------|--------|---------|--------|-----|-------|-----------|----------------|----------|-----------|-------------|
      Table.Profile(Source):  | Column1 | null | null |        | null    | null   |     | 6     | 1         | null           |          |           |             |
    fnTable_Profile(Source):  | Column1 | 1    | 3    | 2      | 2       | 1      | 6   | 6     | 1         | 6              | 1        | zyx       | 3           |
                                  "
                ]
            }
        ]
    )
