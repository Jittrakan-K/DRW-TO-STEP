' test_flip.vbs
On Error Resume Next

Dim fso, swApp, swModel, swPart, swFeatMgr, swSketchMgr, swModelDocExt, swFeat
Dim boolstatus, sldprtPath, templatePath

Set fso = CreateObject("Scripting.FileSystemObject")
sldprtPath = "D:\jittrakan.katprasat\OneDrive - Orbray (Thailand)\ORBRAY 20523\20523 JUNIOR\WORK\PROJECT DOCUMENT\AUTOMATION BUILD 3D SOLIDWORKS\outputs\JIG-MOT097Z001-0.sldprt"

Set swApp = CreateObject("SldWorks.Application")
templatePath = "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot"
Set swModel = swApp.NewDocument(templatePath, 0, 0, 0)
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

' Extrude 10 mm in reverse direction (into -Y)
Set swFeat = swFeatMgr.FeatureExtrusion2(True, True, False, 0, 0, 0.010, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, True, True, True, 0, 0, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Boss-Extrude1 (Plate 145x145x10)"
    WScript.Echo "1. Boss-Extrude1 SUCCESS"
Else
    WScript.Echo "1. Boss-Extrude1 FAILED"
End If

' 2. Select Top Plane & Cut 100 Pockets with Flip = True
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

' Test Flip = True (parameter 2 = True)
Set swFeat = swFeatMgr.FeatureCut4(True, True, False, 0, 0, 0.003, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude1 (100 Pockets Ø11 Depth 3mm)"
    WScript.Echo "2. Cut-Extrude1 100 Pockets with Flip=True SUCCESS!"
Else
    WScript.Echo "2. Cut-Extrude1 with Flip=True FAILED, trying other parameters..."
    ' Try Flip=False, Dir=True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, True, 0, 0, 0.003, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then
        WScript.Echo "2. Cut-Extrude1 with Dir=True SUCCESS!"
    Else
        WScript.Echo "2. Cut-Extrude1 with Dir=True FAILED"
    End If
End If

' 3. Select Top Plane & Cut 4 Corner Holes Ø4.5 Thru All
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.00225
swModel.ClearSelection2 True

Set swFeat = swFeatMgr.FeatureCut4(True, True, False, 1, 0, 0.02, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude2 (4 Corner Holes Ø4.5 Thru)"
    WScript.Echo "3. Cut-Extrude2 Corner Holes SUCCESS"
End If

' 4. Select Top Plane & Cut 4 Counterbores Ø8 depth 4mm with Flip = True
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.004
swModel.ClearSelection2 True

Set swFeat = swFeatMgr.FeatureCut4(True, True, False, 0, 0, 0.004, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude3 (4 Counterbores Ø8 Depth 4mm)"
    WScript.Echo "4. Cut-Extrude3 Counterbores with Flip=True SUCCESS"
Else
    WScript.Echo "4. Cut-Extrude3 Counterbores FAILED"
End If

' Material & Isometric View
swPart.SetMaterialPropertyName2 "Default", "", "Acrylic"
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

swModel.ForceRebuild3 True
swModel.SaveAs3 sldprtPath, 0, 2
WScript.Echo "Final SLDPRT size: " & fso.GetFile(sldprtPath).Size

swApp.CloseDoc swModel.GetTitle
WScript.Quit 0
