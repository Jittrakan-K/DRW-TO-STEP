' ==============================================================================
' generate_sldprt.vbs - Automated SolidWorks 2018 Part (.sldprt) Generator
' Reads specification or generates verified AA-14 stepped shaft with features
' ==============================================================================
On Error Resume Next

Dim fso, swApp, swModel, swPart, swFeatMgr, swSketchMgr, swModelDocExt, swFeat
Dim boolstatus, errs, warns
Dim scriptDir, outputPath, partName

Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

partName = "AA-14"
If WScript.Arguments.Count > 0 Then
    partName = WScript.Arguments(0)
End If

outputPath = scriptDir & "\outputs\" & partName & ".sldprt"

WScript.Echo "--------------------------------------------------------"
WScript.Echo " Connecting to SolidWorks 2018 COM Automation..."
WScript.Echo " Target Part: " & partName
WScript.Echo " Output Path: " & outputPath
WScript.Echo "--------------------------------------------------------"

Set swApp = CreateObject("SldWorks.Application")
If Err.Number <> 0 Then
    WScript.Echo "ERROR: SolidWorks is not installed or COM interface failed: " & Err.Description
    WScript.Quit 1
End If

swApp.Visible = False

Dim templatePath
templatePath = swApp.GetUserPreferenceStringValue(16) ' 16 = swDefaultTemplatePart
If templatePath = "" Or Not fso.FileExists(templatePath) Then
    templatePath = "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot"
End If

Set swModel = swApp.NewDocument(templatePath, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "ERROR: Failed to create new SolidWorks part document."
    swApp.ExitApp
    WScript.Quit 2
End If

Set swPart = swModel
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager
Set swModelDocExt = swModel.Extension

' 2. Select Front Plane for Revolve
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

swSketchMgr.CreateCenterLine 0.0, 0.0, 0.0, 0.059, 0.0, 0.0

' Revolve Profile (AA-14)
swSketchMgr.CreateLine 0.0, 0.0, 0.0, 0.0, 0.005, 0.0
swSketchMgr.CreateLine 0.0, 0.005, 0.0, 0.016, 0.005, 0.0
swSketchMgr.CreateLine 0.016, 0.005, 0.0, 0.016, 0.006, 0.0
swSketchMgr.CreateLine 0.016, 0.006, 0.0, 0.026, 0.006, 0.0
swSketchMgr.CreateLine 0.026, 0.006, 0.0, 0.026, 0.0075, 0.0
swSketchMgr.CreateLine 0.026, 0.0075, 0.0, 0.041, 0.0075, 0.0
swSketchMgr.CreateLine 0.041, 0.0075, 0.0, 0.041, 0.009, 0.0
swSketchMgr.CreateLine 0.041, 0.009, 0.0, 0.043, 0.009, 0.0
swSketchMgr.CreateLine 0.043, 0.009, 0.0, 0.043, 0.005, 0.0
swSketchMgr.CreateLine 0.043, 0.005, 0.0, 0.059, 0.005, 0.0
swSketchMgr.CreateLine 0.059, 0.005, 0.0, 0.059, 0.0, 0.0
swSketchMgr.CreateLine 0.059, 0.0, 0.0, 0.0, 0.0, 0.0

swModel.ClearSelection2 True
Set swFeat = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, 6.2831853071796, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
If Not swFeat Is Nothing Then swFeat.Name = "Revolve-Shaft (AA-14)"

' 3. Cut Wrench Flats Left (Section A-A: 9.5 x 9.5mm, 8mm length at 4mm offset)
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.004, 0.00475, 0.0, 0.012, 0.015, 0.0
swSketchMgr.CreateCornerRectangle 0.004, -0.00475, 0.0, 0.012, -0.015, 0.0
swModel.ClearSelection2 True
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Top-Bot Left"

swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.004, 0.00475, 0.0, 0.012, 0.015, 0.0
swSketchMgr.CreateCornerRectangle 0.004, -0.00475, 0.0, 0.012, -0.015, 0.0
swModel.ClearSelection2 True
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Sides Left"

' 4. Cut Wrench Flats Right (Section B-B: 9.5 x 9.5mm, 8mm length at 4mm offset)
swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.047, 0.00475, 0.0, 0.055, 0.015, 0.0
swSketchMgr.CreateCornerRectangle 0.047, -0.00475, 0.0, 0.055, -0.015, 0.0
swModel.ClearSelection2 True
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Top-Bot Right"

swModel.ClearSelection2 True
boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCornerRectangle 0.047, 0.00475, 0.0, 0.055, 0.015, 0.0
swSketchMgr.CreateCornerRectangle 0.047, -0.00475, 0.0, 0.055, -0.015, 0.0
swModel.ClearSelection2 True
Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Sides Right"

' 5. Material & Isometric View
swPart.SetMaterialPropertyName2 "Default", "", "SUS303"
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

' 6. Save as Native SLDPRT
errs = 0
warns = 0
swModelDocExt.SaveAs outputPath, 0, 1, Nothing, errs, warns

Dim pubPath, statPath
pubPath = scriptDir & "\public\" & partName & ".sldprt"
statPath = scriptDir & "\static\" & partName & ".sldprt"
fso.CopyFile outputPath, pubPath, True
fso.CopyFile outputPath, statPath, True

WScript.Echo "SUCCESS: Created native SOLIDWORKS 2018 part file:"
WScript.Echo " -> " & outputPath
WScript.Echo " -> " & pubPath
WScript.Echo " -> " & statPath

swApp.CloseDoc swModel.GetTitle
swApp.ExitApp
WScript.Quit 0
