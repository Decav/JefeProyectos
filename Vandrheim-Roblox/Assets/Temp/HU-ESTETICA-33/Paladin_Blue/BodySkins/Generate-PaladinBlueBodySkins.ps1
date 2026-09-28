Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $root '..\..\..\..\..')).Path
$shirtMaskPath = Join-Path $projectRoot 'Assets\Clothing\EST-07\hunter_classic_shirt_r15.png'
$pantsMaskPath = Join-Path $projectRoot 'Assets\Clothing\EST-07\hunter_classic_pants_r15.png'
$outShirt = Join-Path $root 'paladin_blue_classic_shirt_r15.png'
$outPants = Join-Path $root 'paladin_blue_classic_pants_r15.png'

$script:g = $null
$script:canvas = $null

function Get-Color([string]$Hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function Fill-Rect([int]$X, [int]$Y, [int]$W, [int]$H, [string]$Color) {
    $brush = New-Object System.Drawing.SolidBrush (Get-Color $Color)
    $script:g.FillRectangle($brush, $X, $Y, $W, $H)
    $brush.Dispose()
}

function Draw-Line([int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [string]$Color, [float]$Width = 1) {
    $pen = New-Object System.Drawing.Pen ((Get-Color $Color), $Width)
    $script:g.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-Poly([object[]]$Points, [string]$Fill, [string]$Stroke = '#07101D', [float]$Width = 1) {
    $pointList = [System.Collections.Generic.List[System.Drawing.Point]]::new()
    foreach ($pair in $Points) {
        $pointList.Add([System.Drawing.Point]::new([int]$pair[0], [int]$pair[1]))
    }
    $pointArray = $pointList.ToArray()
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon($pointArray)
    $brush = New-Object System.Drawing.SolidBrush (Get-Color $Fill)
    $pen = New-Object System.Drawing.Pen ((Get-Color $Stroke), $Width)
    $script:g.FillPath($brush, $path)
    $script:g.DrawPath($pen, $path)
    $brush.Dispose()
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Diamond([int]$Cx, [int]$Cy, [int]$W, [int]$H, [string]$Fill, [string]$Stroke = '#E5C779', [float]$Width = 1) {
    Draw-Poly @(@($Cx, ($Cy - $H)), @(($Cx + $W), $Cy), @($Cx, ($Cy + $H)), @(($Cx - $W), $Cy)) $Fill $Stroke $Width
}

function Draw-Torso {
    # The template layout follows Roblox's standard 585x559 R15 classic-shirt UV.
    Fill-Rect 164 7 391 257 '#101A33'

    # Side faces: fitted midnight cloth, narrow gold piping, no shoulder geometry.
    Fill-Rect 165 73 65 129 '#172747'
    Fill-Rect 360 73 66 129 '#172747'
    Draw-Line 171 78 171 195 '#B88A42' 1.4
    Draw-Line 224 78 224 195 '#314A70' 1.2
    Draw-Line 366 78 366 195 '#314A70' 1.2
    Draw-Line 419 78 419 195 '#B88A42' 1.4
    Draw-Line 178 86 218 86 '#253C61' 1
    Draw-Line 372 86 412 86 '#253C61' 1

    # Front and back torso panels.
    Fill-Rect 231 73 128 130 '#182B4C'
    Fill-Rect 426 73 129 130 '#111D36'
    Fill-Rect 231 8 128 64 '#142443'
    Fill-Rect 231 203 128 61 '#101A31'

    # Collar/neckline on the upper UV face.
    Draw-Line 238 18 352 18 '#B88A42' 2
    Draw-Line 247 25 343 25 '#6F8AA7' 1.2
    Draw-Line 260 18 274 40 '#D7B66B' 1.5
    Draw-Line 330 18 316 40 '#D7B66B' 1.5
    Draw-Line 274 40 292 53 '#B88A42' 1.5
    Draw-Line 316 40 298 53 '#B88A42' 1.5

    # Shaped breastplate is painted directly onto the torso UV.
    Draw-Poly @(@(246,84), @(344,84), @(352,116), @(340,153), @(295,193), @(250,153), @(238,116)) '#536C86' '#D1AC62' 2
    Draw-Poly @(@(249,91), @(291,99), @(288,143), @(255,151), @(243,119)) '#8098AE' '#263C5B' 1
    Draw-Poly @(@(341,91), @(299,99), @(302,143), @(335,151), @(347,119)) '#718AA3' '#263C5B' 1

    # Cool reflections and engraved panel lines.
    Draw-Line 252 96 283 103 '#C0D4E2' 1
    Draw-Line 338 96 307 103 '#C0D4E2' 1
    Draw-Line 250 130 281 139 '#405979' 1.2
    Draw-Line 340 130 309 139 '#405979' 1.2
    Draw-Line 246 119 239 118 '#E5C779' 1.2
    Draw-Line 344 119 351 118 '#E5C779' 1.2

    # Center gorget, blue heraldic gem, and restrained gold inlay.
    Draw-Poly @(@(290,96), @(300,96), @(305,158), @(295,179), @(285,158)) '#18365E' '#D8B96E' 1.5
    Draw-Line 295 101 295 169 '#E7CA7C' 1
    Draw-Diamond 295 119 9 12 '#168BD0' '#E7CA7C' 1.5
    Draw-Diamond 295 119 4 6 '#7CE6FF' '#D7F8FF' 0.8
    Draw-Line 295 133 295 168 '#53B8E6' 1.2

    # Segmented lower breastplate, designed to follow the Roblox torso silhouette.
    Draw-Poly @(@(254,151), @(288,145), @(290,179), @(270,190), @(253,176)) '#405B78' '#B98B43' 1.2
    Draw-Poly @(@(336,151), @(302,145), @(300,179), @(320,190), @(337,176)) '#405B78' '#B98B43' 1.2
    Draw-Line 260 160 283 156 '#AFC3D4' 1
    Draw-Line 330 160 307 156 '#AFC3D4' 1
    Draw-Line 270 178 284 172 '#263C5B' 1
    Draw-Line 320 178 306 172 '#263C5B' 1
    Draw-Line 260 194 330 194 '#D7B66B' 1.2

    # Back panel: matching fabric, central seam and small embossed class crest.
    Fill-Rect 432 80 116 116 '#121F3B'
    Draw-Line 490 82 490 195 '#3C5578' 1.2
    Draw-Line 439 89 481 89 '#B88A42' 1
    Draw-Line 499 89 541 89 '#B88A42' 1
    Draw-Diamond 490 123 10 14 '#203D67' '#B88A42' 1
    Draw-Line 490 108 490 139 '#D4B56C' 1
    Draw-Line 478 123 502 123 '#D4B56C' 1
    Draw-Line 443 184 537 184 '#31496B' 1

    # Waist seam; face top/bottom remain close-fitting cloth.
    Draw-Line 235 207 355 207 '#B88A42' 1.5
    Draw-Line 235 213 355 213 '#2B4262' 1
    Draw-Line 240 250 350 250 '#263A58' 1.2
}

function Draw-ArmIsland([int]$X, [int]$TileX) {
    # Roblox mirrors the front-face column between the right and left arm UV islands.
    $frontX = if ($X -eq 303) { $X } else { $X + 192 }
    $sideX = if ($frontX -gt $X) { $frontX - 64 } else { $frontX + 64 }
    # Each arm is a 4-face x 2-row UV island: fabric above, fitted vambrace below.
    $faceColors = @('#162747', '#111E39', '#1B3156', '#172B4E')
    for ($row = 0; $row -lt 2; $row++) {
        $y = 359 + ($row * 64)
        for ($col = 0; $col -lt 4; $col++) {
            Fill-Rect ($X + ($col * 64)) $y 64 64 $faceColors[$col]
            Draw-Line ($X + ($col * 64) + 5) ($y + 5) ($X + ($col * 64) + 5) ($y + 58) '#2B456A' 1
        }
    }
    # Upper-arm fitted cloth with a single gold seam.
    Fill-Rect ($X + 1) 363 254 52 '#1A3157'
    Draw-Line ($X + 5) 369 ($X + 250) 369 '#314D76' 1
    Draw-Line ($X + 4) 414 ($X + 251) 414 '#B88A42' 2
    Draw-Line ($X + 4) 418 ($X + 251) 418 '#E0C47C' 1

    # Lower-arm metal vambrace appears on the front-facing UV panel, integrated with the skin.
    Draw-Poly @(@(($frontX + 6), 426), @(($frontX + 58), 426), @(($frontX + 58), 475), @(($frontX + 32), 484), @(($frontX + 6), 475)) '#58718B' '#D4B66B' 1.6
    Draw-Poly @(@(($frontX + 12), 431), @(($frontX + 52), 431), @(($frontX + 52), 469), @(($frontX + 32), 477), @(($frontX + 12), 469)) '#718BA5' '#314969' 1
    Draw-Line ($frontX + 32) 434 ($frontX + 32) 472 '#C8D8E4' 1
    Draw-Line ($frontX + 11) 438 ($frontX + 53) 438 '#B88A42' 1.5
    Draw-Line ($frontX + 11) 469 ($frontX + 53) 469 '#B88A42' 1.5
    Draw-Diamond ($frontX + 32) 452 6 8 '#168BD0' '#E5C779' 1

    # Side facets and small rivets keep the gauntlet readable at avatar scale.
    Fill-Rect ($sideX + 4) 430 56 43 '#20385F'
    Draw-Line ($sideX + 9) 435 ($sideX + 55) 435 '#8EA8BF' 1
    Draw-Line ($sideX + 9) 468 ($sideX + 55) 468 '#B88A42' 1
    foreach ($rivetX in @(($sideX + 15), ($sideX + 49))) {
        Fill-Rect $rivetX 447 3 3 '#E5C779'
    }

    # End faces for the cuffs/hand connection.
    Fill-Rect $TileX 295 64 64 '#142443'
    Draw-Poly @(@(($TileX + 11), 307), @(($TileX + 53), 307), @(($TileX + 47), 345), @(($TileX + 17), 345)) '#304A6D' '#B88A42' 1.2
    Draw-Line ($TileX + 17) 315 ($TileX + 47) 315 '#AFC3D4' 1
    Fill-Rect $TileX 488 64 64 '#101A31'
    Draw-Line ($TileX + 8) 496 ($TileX + 56) 496 '#B88A42' 1.4
    Draw-Line ($TileX + 14) 503 ($TileX + 50) 503 '#425D7D' 1
    Draw-Diamond ($TileX + 32) 526 8 10 '#193A63' '#D9BB70' 1
}

function Draw-LegIsland([int]$X, [int]$TileX) {
    # Roblox mirrors the front-face column between right and left leg UV islands.
    $frontX = if ($X -eq 303) { $X } else { $X + 192 }
    $faceColors = @('#152441', '#111D37', '#1B3154', '#182C4C')
    for ($row = 0; $row -lt 2; $row++) {
        $y = 359 + ($row * 64)
        for ($col = 0; $col -lt 4; $col++) {
            Fill-Rect ($X + ($col * 64)) $y 64 64 $faceColors[$col]
            Draw-Line ($X + ($col * 64) + 6) ($y + 5) ($X + ($col * 64) + 6) ($y + 58) '#2A4161' 1
        }
    }
    # Fitted upper-leg panels and engraved front seam.
    Fill-Rect ($X + 1) 363 254 52 '#172B4C'
    Draw-Line ($X + 8) 370 ($X + 247) 370 '#2F496D' 1
    Draw-Line ($X + 6) 416 ($X + 250) 416 '#B88A42' 1.5
    Draw-Poly @(@(($frontX + 6), 367), @(($frontX + 58), 367), @(($frontX + 58), 410), @(($frontX + 32), 416), @(($frontX + 6), 410)) '#1B355C' '#314E73' 1
    Draw-Line ($frontX + 32) 374 ($frontX + 32) 407 '#B88A42' 1
    Draw-Diamond ($frontX + 32) 390 5 8 '#167FBE' '#D8B96E' 1

    # Knee plate and shin guard, painted flush on the lower-leg front.
    Draw-Poly @(@(($frontX + 7), 427), @(($frontX + 32), 422), @(($frontX + 57), 427), @(($frontX + 54), 447), @(($frontX + 32), 456), @(($frontX + 10), 447)) '#8198AE' '#D8B96E' 1.6
    Draw-Poly @(@(($frontX + 13), 431), @(($frontX + 32), 427), @(($frontX + 51), 431), @(($frontX + 49), 444), @(($frontX + 32), 451), @(($frontX + 15), 444)) '#5A738E' '#2B4260' 1
    Draw-Diamond ($frontX + 32) 439 5 7 '#168BD0' '#E8CA7B' 1
    Draw-Poly @(@(($frontX + 15), 455), @(($frontX + 49), 455), @(($frontX + 54), 479), @(($frontX + 32), 485), @(($frontX + 10), 479)) '#354F70' '#B88A42' 1.4
    Draw-Line ($frontX + 32) 458 ($frontX + 32) 477 '#AFC3D4' 1
    Draw-Line ($frontX + 17) 460 ($frontX + 47) 460 '#D5B66A' 1
    Draw-Line ($frontX + 15) 477 ($frontX + 49) 477 '#D5B66A' 1

    # Boot/top/bottom UV faces with dark leather and a fine gold welt.
    Fill-Rect $TileX 295 64 64 '#14213B'
    Draw-Line ($TileX + 7) 303 ($TileX + 57) 303 '#B88A42' 1.5
    Draw-Line ($TileX + 14) 311 ($TileX + 50) 311 '#304969' 1
    Draw-Diamond ($TileX + 32) 333 7 9 '#18365D' '#B88A42' 1
    Fill-Rect $TileX 488 64 64 '#0E172A'
    Draw-Poly @(@(($TileX + 5), 492), @(($TileX + 59), 492), @(($TileX + 54), 535), @(($TileX + 10), 535)) '#263D5D' '#B88A42' 1.3
    Draw-Line ($TileX + 12) 530 ($TileX + 52) 530 '#D2B46A' 1.5
}

function Export-MaskedTexture([string]$MaskPath, [string]$OutputPath, [scriptblock]$Paint) {
    $mask = [System.Drawing.Bitmap]::FromFile($MaskPath)
    if ($mask.Width -ne 585 -or $mask.Height -ne 559) {
        throw "Expected 585x559 UV mask, received $($mask.Width)x$($mask.Height): $MaskPath"
    }
    $script:canvas = New-Object System.Drawing.Bitmap 585, 559, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $script:g = [System.Drawing.Graphics]::FromImage($script:canvas)
    $script:g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $script:g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $script:g.Clear((Get-Color '#101A33'))
    & $Paint
    $script:g.Dispose()
    $script:g = $null

    $opaquePixels = 0
    for ($y = 0; $y -lt 559; $y++) {
        for ($x = 0; $x -lt 585; $x++) {
            $m = $mask.GetPixel($x, $y)
            if ($m.A -gt 0) {
                $c = $script:canvas.GetPixel($x, $y)
                $script:canvas.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($m.A, $c.R, $c.G, $c.B))
                $opaquePixels++
            } else {
                $script:canvas.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            }
        }
    }
    $script:canvas.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $mask.Dispose()
    $script:canvas.Dispose()
    $script:canvas = $null
    [PSCustomObject]@{ File = $OutputPath; Width = 585; Height = 559; OpaqueUVPixels = $opaquePixels }
}

$shirtResult = Export-MaskedTexture $shirtMaskPath $outShirt {
    Draw-Torso
    Draw-ArmIsland 15 215
    Draw-ArmIsland 303 303
}

$pantsResult = Export-MaskedTexture $pantsMaskPath $outPants {
    Draw-LegIsland 15 215
    Draw-LegIsland 303 303
}

$shirtResult
$pantsResult
