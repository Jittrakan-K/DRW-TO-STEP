' ******************************************************************************
' SolidWorks VBA Macro: Automatic 3D Parametric Feature Tree
' Generated for: AA-14
' Material: SUS303
' Compatible with: SolidWorks 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026+
' ******************************************************************************

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swPart As Object
Dim swFeatMgr As Object
Dim swSketchMgr As Object
Dim swModelDocExt As Object
Dim swFeat As Object
Dim boolstatus As Boolean

Sub main()

    Set swApp = Application.SldWorks
    Set swModel = swApp.ActiveDoc

    If swModel Is Nothing Then
        Dim defaultPartTemplate As String
        defaultPartTemplate = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplatePart)
        If defaultPartTemplate = "" Then
            defaultPartTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot"
        End If
        Set swModel = swApp.NewDocument(defaultPartTemplate, 0, 0, 0)
    End If

    If swModel Is Nothing Then
        MsgBox "กรุณาเปิด SolidWorks และสร้าง Part ใหม่", vbCritical, "SolidWorks Automation"
        Exit Sub
    End If

    Set swPart = swModel
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swModelDocExt = swModel.Extension

    ' 1. Select Front Plane
    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    ' Centerline axis
    swSketchMgr.CreateCenterLine 0#, 0#, 0#, 0.059000, 0#, 0#

    ' Revolve Contour
    swSketchMgr.CreateLine 0#, 0#, 0#, 0#, 0.005000, 0#
    swSketchMgr.CreateLine 0.000000, 0.005000, 0#, 0.016000, 0.005000, 0#
    swSketchMgr.CreateLine 0.016000, 0.005000, 0#, 0.016000, 0.006000, 0#
    swSketchMgr.CreateLine 0.016000, 0.006000, 0#, 0.026000, 0.006000, 0#
    swSketchMgr.CreateLine 0.026000, 0.006000, 0#, 0.026000, 0.007500, 0#
    swSketchMgr.CreateLine 0.026000, 0.007500, 0#, 0.041000, 0.007500, 0#
    swSketchMgr.CreateLine 0.041000, 0.007500, 0#, 0.041000, 0.009000, 0#
    swSketchMgr.CreateLine 0.041000, 0.009000, 0#, 0.043000, 0.009000, 0#
    swSketchMgr.CreateLine 0.043000, 0.009000, 0#, 0.043000, 0.005000, 0#
    swSketchMgr.CreateLine 0.043000, 0.005000, 0#, 0.059000, 0.005000, 0#
    swSketchMgr.CreateLine 0.059000, 0.005000, 0#, 0.059000, 0#, 0#
    swSketchMgr.CreateLine 0.059000, 0#, 0#, 0#, 0#, 0#

    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, 6.2831853071796, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Revolve-Body"
    End If

    ' 2. Cut-Extrude Wrench Flats
    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.004000, 0.004750, 0#, 0.012000, 0.015, 0#
    swSketchMgr.CreateCornerRectangle 0.004000, -0.004750, 0#, 0.012000, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Top-Bot #1"

    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.004000, 0.004750, 0#, 0.012000, 0.015, 0#
    swSketchMgr.CreateCornerRectangle 0.004000, -0.004750, 0#, 0.012000, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Sides #1"
    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.047000, 0.004750, 0#, 0.055000, 0.015, 0#
    swSketchMgr.CreateCornerRectangle 0.047000, -0.004750, 0#, 0.055000, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Top-Bot #5"

    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.047000, 0.004750, 0#, 0.055000, 0.015, 0#
    swSketchMgr.CreateCornerRectangle 0.047000, -0.004750, 0#, 0.055000, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Sides #5"

    ' 3. Set Material: SUS303
    swPart.SetMaterialPropertyName2 "Default", "", "SUS303"

    ' 4. Isometric View
    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2

    MsgBox "สร้างโมเดล AA-14 พร้อม Feature Tree ใน SolidWorks สำเร็จ!", vbInformation, "SolidWorks Automation"

End Sub
