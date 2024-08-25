<?php
// Fetch the server's hostname
$hostname = gethostname();

// Fetch GCP instance metadata
$metadataUrl = 'http://metadata.google.internal/computeMetadata/v1/instance/?recursive=true';
$options = [
    'http' => [
        'method' => 'GET',
        'header' => 'Metadata-Flavor: Google'
    ]
];
$context = stream_context_create($options);
$metadataJson = file_get_contents($metadataUrl, false, $context);

// Decode the JSON metadata
$metadata = json_decode($metadataJson, true);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>This is prod server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f0f4f8;
            color: #333;
        }
        h1 {
            color: #2c3e50;
        }
        h2 {
            color: #2980b9;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            background-color: #ffffff;
        }
        table, th, td {
            border: 1px solid #bdc3c7;
        }
        th {
            padding: 10px;
            text-align: left;
            background-color: #34495e;
            color: #ecf0f1;
        }
        td {
            padding: 10px;
            text-align: left;
        }
        /* Alternating row colors */
        tbody tr:nth-child(odd) {
            background-color: #e3f2fd; /* Light Blue */
        }
        tbody tr:nth-child(even) {
            background-color: #e8f5e9; /* Light Green */
        }
        tbody tr:nth-child(4n+1) td {
            background-color: #fff9c4; /* Light Yellow */
        }
        pre {
            margin: 0;
            background-color: inherit;
            padding: 10px;
            border-radius: 4px;
            overflow-x: auto;
            font-size: 14px;
            font-family: Consolas, monospace;
        }
        .greeting {
            font-size: 24px;
            color: #27ae60; /* Green */
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="greeting">Hello! This is prod server :)</div>
    <h1>Server Information</h1>
    <p>Hostname: <strong><?php echo htmlspecialchars($hostname); ?></strong></p>
    <h2>GCP Instance Metadata</h2>
    <table>
        <thead>
            <tr>
                <th>Attribute</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($metadata as $key => $value): ?>
                <tr>
                    <td><?php echo htmlspecialchars($key); ?></td>
                    <td>
                        <?php
                        if (is_array($value) || is_object($value)) {
                            echo '<pre>' . htmlspecialchars(json_encode($value, JSON_PRETTY_PRINT)) . '</pre>';
                        } else {
                            echo htmlspecialchars($value);
                        }
                        ?>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>