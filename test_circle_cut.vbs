Dim fso, swApp, swModel, swPart, swFeatMgr, swSketchMgr, swModelDocExt, swFeat
Set fso = CreateObject("Scripting.FileSystemObject")
Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

Dim tpl
tpl = "C:\ProgramData\SolidWorks\SOLIDWORKS 2024\templates\Part.PRTDOT"
Set swModel = swApp.NewDocument(tpl, 0, 0, 0)
Set swPart = swModel
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager
Set swModelDocExt = swModel.Extension

' Base Block
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.0, 0.0, 0.0, 0.145, 0.145, 0.0
swModel.ClearSelection2 True
' Extrude down 10mm
swFeatMgr.FeatureExtrusion2 True, True, False, 0, 0, 0.010, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, True, True, True, 0, 0, False

' Test 100 circles cut on Top Plane
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

Set swFeat = swFeatMgr.FeatureCut4(True, False, True, 0, 0, 0.003, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude1 (100 Pockets Ø11 Depth 3mm)"
    WScript.Echo "100 pockets SUCCESS"
End If

' 4 Corner Through Holes Ø4.5 Thru All
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.00225
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.00225
swModel.ClearSelection2 True

Set swFeat = swFeatMgr.FeatureCut4(True, False, True, 1, 0, 0.02, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude2 (4 Corner Holes Ø4.5 Thru)"
    WScript.Echo "4 Through holes SUCCESS"
End If

' 4 Counterbores Ø8 Depth 4mm
swModel.ClearSelection2 True
swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.005, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.005, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.005, 0.140, 0.0, 0.004
swSketchMgr.CreateCircleByRadius 0.140, 0.140, 0.0, 0.004
swModel.ClearSelection2 True

Set swFeat = swFeatMgr.FeatureCut4(True, False, True, 0, 0, 0.004, 0.01, False, False, False, False, 0.0, 0.0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then
    swFeat.Name = "Cut-Extrude3 (4 Counterbores Ø8 Depth 4mm)"
    WScript.Echo "4 Counterbores SUCCESS"
End If

' Set Material: Black Acrylic
swPart.SetMaterialPropertyName2 "Default", "", "Acrylic"

' Rebuild
swModel.ForceRebuild3 True

' Save as SLDPRT and STEP
Dim sldprtPath, stepPath
sldprtPath = "D:\etc\WORK\PROJECT DOCUMENT\AUTOMATION BUILD 3D SOLIDWORKS\outputs\JIG-MOT097Z001-0.sldprt"
stepPath = "D:\etc\WORK\PROJECT DOCUMENT\AUTOMATION BUILD 3D SOLIDWORKS\outputs\JIG-MOT097Z001-0_AP203.step"
swModel.SaveAs3 sldprtPath, 0, 2
swModel.SaveAs3 stepPath, 0, 2

' Export image from Bottom
swModel.ShowNamedView2 "*Bottom", 5
swModel.ViewZoomtofit2
swModel.SaveAs3 "D:\etc\WORK\PROJECT DOCUMENT\AUTOMATION BUILD 3D SOLIDWORKS\outputs\test_bottom_view.png", 0, 2
WScript.Echo "Exported test_bottom_view.png successfully!"


swApp.CloseDoc swModel.GetTitle
WScript.Quit 0
