(inputTable as table) as table =>
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
                MedianValue    = List.Max(                columnData ),
                MaxValue       = List.Median(             columnData )
            ]
    ),
    result = Table.FromRecords(profile)
in
    result
