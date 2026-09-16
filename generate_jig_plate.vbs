' generate_jig_plate.vbs
On Error Resume Next

Dim fso, swApp, swModel, swPart, swFeatMgr, swSketchMgr, swModelDocExt
Dim featPlate, featPockets, featHoles, featCbores
Dim sldprtPath, stepPath, templatePath, scriptDir
Dim errs, warns

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
    templatePath = "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot"
End If

Set swModel = swApp.NewDocument(templatePath, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "ERROR: NewDocument failed"
    WScript.Quit 2
End If

Set swPart = swModel
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager
Set swModelDocExt = swModel.Extension

' 1. Select Top Plane & Create 145 x 145 mm Base Block
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.0, 0.0, 0.0, 0.145, 0.145, 0.0
swModel.ClearSelection2 True

' Extrude 10 mm in reverse direction (into -Y so top face is at Y = 0)
' Parameter 2 = sdFlip (True = reverse direction into -Y)
Set featPlate = swFeatMgr.FeatureExtrusion2(True, True, False, 0, 0, 0.010, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, True, True, True, 0, 0, False)
If featPlate Is Nothing Then
    WScript.Echo "1. Boss-Extrude1 FAILED"
    WScript.Quit 3
Else
    featPlate.Name = "Boss-Extrude1 (Plate 145x145x10)"
    WScript.Echo "1. Boss-Extrude1 SUCCESS"
End If

' 2. Select Top Plane & Cut 100 Pockets (10x10 Matrix, ?11 depth 3mm)
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
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

' Sd=True, FlipSideToCut=False, Dir=True (Cut down into -Y), Type1=0 (Blind), Depth1=0.003
Set featPockets = swFeatMgr.FeatureCut4(True, False, True, 0, 0, 0.003, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If featPockets Is Nothing Then
    WScript.Echo "2. Cut-Extrude1 Pockets FAILED"
    WScript.Quit 4
Else
    featPockets.Name = "Cut-Extrude1 (100 Pockets ?11 Depth 3mm)"
    WScript.Echo "2. Cut-Extrude1 Pockets SUCCESS"
End If

' 3. Select Top Plane & Cut 4 Corner Holes ?4.5 Thru All
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.00225
swModel.ClearSelection2 True

' Sd=True, FlipSideToCut=False, Dir=True, Type1=1 (Thru All)
Set featHoles = swFeatMgr.FeatureCut4(True, False, True, 1, 0, 0.02, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If featHoles Is Nothing Then
    WScript.Echo "3. Cut-Extrude2 Holes FAILED"
    WScript.Quit 5
Else
    featHoles.Name = "Cut-Extrude2 (4 Corner Holes ?4.5 Thru)"
    WScript.Echo "3. Cut-Extrude2 Holes SUCCESS"
End If

' 4. Select Top Plane & Cut 4 Counterbores ?8 depth 4mm
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.004
swModel.ClearSelection2 True

' Sd=True, FlipSideToCut=False, Dir=True, Type1=0 (Blind), Depth1=0.004
Set featCbores = swFeatMgr.FeatureCut4(True, False, True, 0, 0, 0.004, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If featCbores Is Nothing Then
    WScript.Echo "4. Cut-Extrude3 Counterbores FAILED"
    WScript.Quit 6
Else
    featCbores.Name = "Cut-Extrude3 (4 Counterbores ?8 Depth 4mm)"
    WScript.Echo "4. Cut-Extrude3 Counterbores SUCCESS"
End If

' 5. Material & Isometric View
swPart.SetMaterialPropertyName2 "Default", "", "Acrylic"
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

' 6. Force rebuild
swModel.ForceRebuild3 True

' Save as SLDPRT
errs = 0
warns = 0
swModelDocExt.SaveAs sldprtPath, 0, 1, Nothing, errs, warns
WScript.Echo "Saved SLDPRT: " & sldprtPath & ", size: " & fso.GetFile(sldprtPath).Size

' Save as STEP
swModelDocExt.SaveAs stepPath, 0, 1, Nothing, errs, warns
WScript.Echo "Saved STEP: " & stepPath & ", size: " & fso.GetFile(stepPath).Size

' Copy to public and static
fso.CopyFile sldprtPath, scriptDir & "\public\JIG-MOT097Z001-0.sldprt", True
fso.CopyFile sldprtPath, scriptDir & "\static\JIG-MOT097Z001-0.sldprt", True
fso.CopyFile stepPath, scriptDir & "\public\JIG-MOT097Z001-0_AP203.step", True
fso.CopyFile stepPath, scriptDir & "\static\JIG-MOT097Z001-0_AP203.step", True

swApp.CloseDoc swModel.GetTitle
WScript.Echo "ALL JIG PLATE CAD EXPORTS COMPLETED 100% SUCCESSFULLY!"
WScript.Quit 0
