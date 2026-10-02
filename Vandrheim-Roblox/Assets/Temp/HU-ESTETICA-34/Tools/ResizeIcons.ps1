param(
    [string]$SourceFolder = (Join-Path $PSScriptRoot '..\Icons'),
    [string]$DestinationFolder = (Join-Path $PSScriptRoot '..\Icons_512')
)
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force -Path $DestinationFolder | Out-Null
foreach ($sourceFile in Get-ChildItem -LiteralPath $SourceFolder -Filter '*.png' -File) {
    $sourceImage = [System.Drawing.Image]::FromFile($sourceFile.FullName)
    try {
        $bitmap = [System.Drawing.Bitmap]::new(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage($sourceImage, 0, 0, 512, 512)
                $destinationPath = Join-Path $DestinationFolder $sourceFile.Name
                $stream = [System.IO.File]::Open($destinationPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
                try { $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png) } finally { $stream.Dispose() }
                $alpha = $bitmap.GetPixel(0,0).A
                [pscustomobject]@{Name=$sourceFile.Name;Width=$bitmap.Width;Height=$bitmap.Height;CornerAlpha=$alpha;Bytes=(Get-Item -LiteralPath $destinationPath).Length}
            } finally { $graphics.Dispose() }
        } finally { $bitmap.Dispose() }
    } finally { $sourceImage.Dispose() }
}
