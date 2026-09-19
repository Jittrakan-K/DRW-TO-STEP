' test_perfect_plate.vbs
On Error Resume Next

Dim fso, swApp, swModel, swPart, swFeatMgr, swSketchMgr, swModelDocExt, swFeat
Dim boolstatus, sldprtPath, stepPath, templatePath, scriptDir
Dim nErrors, nWarnings

Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
sldprtPath = scriptDir & "\outputs\JIG-MOT097Z001-0.sldprt"
stepPath = scriptDir & "\outputs\JIG-MOT097Z001-0_AP203.step"

Set swApp = CreateObject("SldWorks.Application")
If swApp Is Nothing Then
    WScript.Echo "ERROR: SldWorks.Application is Nothing"
    WScript.Quit 1
End If

templatePath = swApp.GetUserPreferenceStringValue(16)
If templatePath = "" Or Not fso.FileExists(templatePath) Then
    templatePath = swApp.GetDocumentTemplate(1, "", 0, 0, 0)
End If
If templatePath = "" Or Not fso.FileExists(templatePath) Then
    Dim candidates, cand
    candidates = Array( _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2024\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2023\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2022\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2021\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2020\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2019\templates\Part.PRTDOT", _
        "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot" _
    )
    For Each cand In candidates
        If fso.FileExists(cand) Then
            templatePath = cand
            Exit For
        End If
    Next
End If

WScript.Echo "Using Template: " & templatePath

Set swModel = swApp.NewDocument(templatePath, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "ERROR: NewDocument failed"
    WScript.Quit 2
End If

swApp.Visible = True

Set swPart = swModel
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager
Set swModelDocExt = swModel.Extension


' 1. Select Top Plane & Create 145 x 145 mm Base Block
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
WScript.Echo "1. Select Top Plane: " & boolstatus

swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.0, 0.0, 0.0, 0.145, 0.145, 0.0
swModel.ClearSelection2 True

' Extrude 10 mm in reverse direction (into -Y so top face is at Y = 0)
' Parameter 2 = sdFlip (True = reverse direction into -Y)
Set swFeat = swFeatMgr.FeatureExtrusion2(True, True, False, 0, 0, 0.010, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, True, True, True, 0, 0, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Boss-Extrude1 (Plate 145x145x10)"
    WScript.Echo "1. Boss-Extrude1 SUCCESS"
Else
    WScript.Echo "1. Boss-Extrude1 FAILED"
End If

' 2. Select Top Plane & Cut 100 Pockets (10x10 Matrix, Ø11 depth 3mm)
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
WScript.Echo "2. Select Top Plane for Pockets: " & boolstatus

swSketchMgr.InsertSketch True
Dim r, c, px, py
For r = 0 To 9
    For c = 0 To 9
        px = 0.015 + c * 0.012778
        py = 0.015 + r * 0.012778
        swSketchMgr.CreateCircleByRadius px, py, 0.0, 0.0055
    Next
Next
swModel.ClearSelection2 True

' Cut 3 mm into -Y (sdFlip = False or True depending on direction)
' sdFlip = False cuts into the material (-Y)
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.003, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude1 (100 Pockets Ø11 Depth 3mm)"
    WScript.Echo "2. Cut-Extrude1 100 Pockets SUCCESS"
Else
    WScript.Echo "2. Cut-Extrude1 100 Pockets FAILED"
End If

' 3. Select Top Plane & Cut 4 Corner Holes Ø4.5 Thru All
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
WScript.Echo "3. Select Top Plane for Corner Holes: " & boolstatus

swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.00225
swModel.ClearSelection2 True

' Cut Thru All into -Y (1 = swEndCondThroughAllBoth or swEndCondThroughAll)
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 1, 0, 0.02, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude2 (4 Corner Holes Ø4.5 Thru)"
    WScript.Echo "3. Cut-Extrude2 Corner Holes SUCCESS"
Else
    WScript.Echo "3. Cut-Extrude2 Corner Holes FAILED"
End If

' 4. Select Top Plane & Cut 4 Counterbores Ø8 depth 4mm
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.004
swModel.ClearSelection2 True

Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.004, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude3 (4 Counterbores Ø8 Depth 4mm)"
    WScript.Echo "4. Cut-Extrude3 Counterbores SUCCESS"
Else
    WScript.Echo "4. Cut-Extrude3 Counterbores FAILED"
End If

' 5. Material & Isometric View
swPart.SetMaterialPropertyName2 "Default", "", "Acrylic"
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

' Force rebuild
swModel.ForceRebuild3 True

' Save as SLDPRT
swModel.SaveAs3 sldprtPath, 0, 2
WScript.Echo "Saved SLDPRT: " & sldprtPath & ", size: " & fso.GetFile(sldprtPath).Size

' Also export STEP AP203
swModel.SaveAs3 stepPath, 0, 2
WScript.Echo "Saved STEP: " & stepPath & ", size: " & fso.GetFile(stepPath).Size

' Save snapshot image
Dim imgPath
imgPath = scriptDir & "\outputs\jig_plate_sw_snap.png"
swModel.SaveAs3 imgPath, 0, 2
WScript.Echo "Saved snapshot: " & imgPath & " (Exists: " & fso.FileExists(imgPath) & ")"

' Copy to public and static
fso.CopyFile sldprtPath, scriptDir & "\public\JIG-MOT097Z001-0.sldprt", True
fso.CopyFile sldprtPath, scriptDir & "\static\JIG-MOT097Z001-0.sldprt", True
fso.CopyFile stepPath, scriptDir & "\public\JIG-MOT097Z001-0_AP203.step", True
fso.CopyFile stepPath, scriptDir & "\static\JIG-MOT097Z001-0_AP203.step", True

swApp.CloseDoc swModel.GetTitle
WScript.Quit 0
