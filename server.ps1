$port = 3000
$prefix = "http://localhost:$port/"
$rootPath = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "Server started and listening at $prefix"
} catch {
    Write-Error "Failed to start listener on ${prefix}: $_"
    exit 1
}

# Create messages store if not exists
$dataDir = Join-Path $rootPath "data"
if (!(Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}
$messagesFile = Join-Path $dataDir "messages.json"
if (!(Test-Path $messagesFile)) {
    "[]" | Set-Content -Path $messagesFile -Encoding UTF8
}

$projects = @(
    @{
        id = "1"
        title = "E-Commerce Web Application"
        slug = "ecommerce-web-app"
        shortDescription = "A scalable full-stack store built with modern web technologies and seamless payment integration."
        description = "Full featured e-commerce application with dynamic catalog, basket, checkout, and admin analytics."
        thumbnail = "assets/projects/ecommerce.jpg"
        category = "Web Development"
        featured = $true
        displayOrder = 1
    },
    @{
        id = "2"
        title = "Fitness Tracker Mobile App"
        slug = "fitness-tracker-app"
        shortDescription = "Cross-platform iOS and Android application featuring real-time data sync and analytics."
        description = "Real-time step and workout tracking with social leaderboards and custom fitness routines."
        thumbnail = "assets/projects/fitness.jpg"
        category = "App Development"
        featured = $true
        displayOrder = 2
    },
    @{
        id = "3"
        title = "Cinematic Brand Commercial"
        slug = "cinematic-brand-commercial"
        shortDescription = "High-quality commercial edit with professional color grading, sound design, and VFX."
        description = "Produced 4K promotional commercial utilizing DaVinci Resolve and Adobe Premiere Pro."
        thumbnail = "assets/projects/commercial.jpg"
        category = "Video Editing"
        featured = $true
        displayOrder = 3
    },
    @{
        id = "4"
        title = "AI Customer Support Agent"
        slug = "ai-customer-support-agent"
        shortDescription = "An intelligent automation workflow reducing manual support tickets by 80% with custom LLMs."
        description = "Context-aware conversational agent with vector search embeddings and CRM integrations."
        thumbnail = "assets/projects/ai-agent.jpg"
        category = "AI & Automation"
        featured = $true
        displayOrder = 4
    }
)

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    # Enable CORS
    $response.AddHeader("Access-Control-Allow-Origin", "*")
    $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $response.AddHeader("Access-Control-Allow-Headers", "Content-Type")

    if ($request.HttpMethod -eq "OPTIONS") {
        $response.StatusCode = 200
        $response.Close()
        continue
    }

    $rawUrl = $request.Url.AbsolutePath

    # Route: GET /api/projects
    if ($rawUrl -eq "/api/projects" -and $request.HttpMethod -eq "GET") {
        $jsonResponse = @{
            success = $true
            data = $projects
        } | ConvertTo-Json -Depth 5
        
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
        $response.ContentType = "application/json"
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
        continue
    }

    # Route: POST /api/contact
    if ($rawUrl -eq "/api/contact" -and $request.HttpMethod -eq "POST") {
        $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
        $body = $reader.ReadToEnd()
        $reader.Close()

        try {
            $data = $body | ConvertFrom-Json
            if ([string]::IsNullOrWhiteSpace($data.name) -or [string]::IsNullOrWhiteSpace($data.email) -or [string]::IsNullOrWhiteSpace($data.message)) {
                $errorResponse = @{
                    success = $false
                    error = @{
                        code = "VALIDATION_ERROR"
                        message = "Name, email, and message are required fields."
                    }
                } | ConvertTo-Json
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($errorResponse)
                $response.StatusCode = 400
                $response.ContentType = "application/json"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.Close()
                continue
            }

            # Save message
            $existing = Get-Content -Path $messagesFile -Raw | ConvertFrom-Json
            if ($null -eq $existing) { $existing = @() }
            $newMessage = @{
                id = [System.Guid]::NewGuid().ToString()
                name = $data.name
                email = $data.email
                subject = $data.subject
                message = $data.message
                status = "unread"
                createdAt = (Get-Date).ToString("o")
            }
            $existing += $newMessage
            $existing | ConvertTo-Json -Depth 5 | Set-Content -Path $messagesFile -Encoding UTF8

            $successResponse = @{
                success = $true
                message = "Your message has been sent successfully!"
            } | ConvertTo-Json

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($successResponse)
            $response.StatusCode = 201
            $response.ContentType = "application/json"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            continue
        } catch {
            $err = @{
                success = $false
                error = @{
                    code = "INTERNAL_SERVER_ERROR"
                    message = $_.Exception.Message
                }
            } | ConvertTo-Json
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($err)
            $response.StatusCode = 500
            $response.ContentType = "application/json"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            continue
        }
    }

    # Route: GET /api/admin/messages
    if ($rawUrl -eq "/api/admin/messages" -and $request.HttpMethod -eq "GET") {
        $msgs = @()
        if (Test-Path $messagesFile) {
            try {
                $raw = Get-Content -Path $messagesFile -Raw
                if (![string]::IsNullOrWhiteSpace($raw)) {
                    $msgs = $raw | ConvertFrom-Json
                }
            } catch {}
        }
        $jsonResponse = @{
            success = $true
            data = $msgs
        } | ConvertTo-Json -Depth 5
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
        $response.ContentType = "application/json"
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
        continue
    }

    # Route: /admin redirect to admin.html
    if ($rawUrl -eq "/admin" -or $rawUrl -eq "/admin/") {
        $rawUrl = "/admin.html"
    }

    # Static file handling
    $relPath = $rawUrl.TrimStart('/')
    if ([string]::IsNullOrEmpty($relPath) -or $relPath -eq "index.html") {
        $filePath = Join-Path $rootPath "index.html"
    } else {
        $filePath = Join-Path $rootPath ($relPath -replace '/', '\')
    }

    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        switch ($ext) {
            ".html" { $response.ContentType = "text/html; charset=utf-8" }
            ".css"  { $response.ContentType = "text/css; charset=utf-8" }
            ".js"   { $response.ContentType = "application/javascript; charset=utf-8" }
            ".png"  { $response.ContentType = "image/png" }
            ".jpg"  { $response.ContentType = "image/jpeg" }
            ".jpeg" { $response.ContentType = "image/jpeg" }
            ".svg"  { $response.ContentType = "image/svg+xml" }
            ".json" { $response.ContentType = "application/json; charset=utf-8" }
            default { $response.ContentType = "application/octet-stream" }
        }

        try {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } catch {
            $response.StatusCode = 500
        }
    } else {
        $response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $response.OutputStream.Write($msg, 0, $msg.Length)
    }

    $response.Close()
}
