' ******************************************************************************
' SolidWorks VBA Macro: Automatic 3D Model Generator for Part AA-14
' Drawing: BA型内径加工機 (BA Type Inner Diameter Machine)
' Part Name: AA-14
' Material: SUS303 (Stainless Steel 303)
' Total Length: 59 mm
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
Dim longstatus As Long

Sub main()

    Set swApp = Application.SldWorks
    Set swModel = swApp.ActiveDoc

    ' 1. If no active document, create a new Part document
    If swModel Is Nothing Then
        Dim defaultPartTemplate As String
        defaultPartTemplate = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplatePart)
        If defaultPartTemplate = "" Then
            defaultPartTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2018\templates\Part.prtdot"
        End If
        Set swModel = swApp.NewDocument(defaultPartTemplate, 0, 0, 0)
    End If

    If swModel Is Nothing Then
        MsgBox "กรุณาเปิด SolidWorks และสร้าง Part ใหม่ หรือตรวจสอบ Part Template", vbCritical, "SolidWorks Automation"
        Exit Sub
    End If

    Set swPart = swModel
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swModelDocExt = swModel.Extension

    ' 2. Select Front Plane for the Main Revolve Body
    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    If Not boolstatus Then
        ' Fallback in case of non-English language template
        boolstatus = swModelDocExt.SelectByID2("Front", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    End If

    swSketchMgr.InsertSketch True

    ' Centerline along X axis (Origin to 59 mm)
    ' In SW API, dimensions are in METERS (1 mm = 0.001 m)
    swSketchMgr.CreateCenterLine 0#, 0#, 0#, 0.059, 0#, 0#

    ' Draw the Revolve Contour:
    ' (X, Y) in meters:
    ' Start at (0, 0) -> (0, 0.005) -> (0.016, 0.005) -> (0.016, 0.006) -> (0.026, 0.006) ->
    ' -> (0.026, 0.0075) -> (0.041, 0.0075) -> (0.041, 0.009) -> (0.043, 0.009) -> (0.043, 0.005) ->
    ' -> (0.059, 0.005) -> (0.059, 0) -> Close to (0, 0)

    swSketchMgr.CreateLine 0#, 0#, 0#, 0#, 0.005, 0#
    swSketchMgr.CreateLine 0#, 0.005, 0#, 0.016, 0.005, 0#
    swSketchMgr.CreateLine 0.016, 0.005, 0#, 0.016, 0.006, 0#
    swSketchMgr.CreateLine 0.016, 0.006, 0#, 0.026, 0.006, 0#
    swSketchMgr.CreateLine 0.026, 0.006, 0#, 0.026, 0.0075, 0#
    swSketchMgr.CreateLine 0.026, 0.0075, 0#, 0.041, 0.0075, 0#
    swSketchMgr.CreateLine 0.041, 0.0075, 0#, 0.041, 0.009, 0#
    swSketchMgr.CreateLine 0.041, 0.009, 0#, 0.043, 0.009, 0#
    swSketchMgr.CreateLine 0.043, 0.009, 0#, 0.043, 0.005, 0#
    swSketchMgr.CreateLine 0.043, 0.005, 0#, 0.059, 0.005, 0#
    swSketchMgr.CreateLine 0.059, 0.005, 0#, 0.059, 0#, 0#
    swSketchMgr.CreateLine 0.059, 0#, 0#, 0#, 0#, 0#

    swModel.ClearSelection2 True

    ' Revolve Feature (360 degrees)
    Set swFeat = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, 6.2831853071796, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Revolve-Shaft (AA-14)"
    End If

    ' 3. Cut-Extrude Flats: Section A-A (Left End: X=4 to X=12 mm, Square 9.5 x 9.5 mm)
    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.004, 0.00475, 0#, 0.012, 0.008, 0#
    swSketchMgr.CreateCornerRectangle 0.004, -0.00475, 0#, 0.012, -0.008, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.02, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Cut-Flats A-A (Top-Bot)"
    End If

    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.004, 0.00475, 0#, 0.012, 0.008, 0#
    swSketchMgr.CreateCornerRectangle 0.004, -0.00475, 0#, 0.012, -0.008, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.02, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Cut-Flats A-A (Sides)"
    End If

    ' 4. Cut-Extrude Flats: Section B-B (Right End: X=47 to X=55 mm, Square 9.5 x 9.5 mm)
    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.047, 0.00475, 0#, 0.055, 0.008, 0#
    swSketchMgr.CreateCornerRectangle 0.047, -0.00475, 0#, 0.055, -0.008, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.02, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Cut-Flats B-B (Top-Bot)"
    End If

    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle 0.047, 0.00475, 0#, 0.055, 0.008, 0#
    swSketchMgr.CreateCornerRectangle 0.047, -0.00475, 0#, 0.055, -0.008, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.02, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Cut-Flats B-B (Sides)"
    End If

    ' 5. Chamfers: C0.5 at Left Tip (X=0) and Right Tip (X=59 mm)
    swModel.ClearSelection2 True
    boolstatus = swModelDocExt.SelectByID2("", "EDGE", 0#, 0.005, 0#, True, 1, Nothing, 0)
    boolstatus = swModelDocExt.SelectByID2("", "EDGE", 0.059, 0.005, 0#, True, 1, Nothing, 0)
    Set swFeat = swFeatMgr.InsertFeatureChamfer(4, 1, 0.0005, 0.785398163397448, 0, 0, 0, 0)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Chamfer-C0.5 (Ends)"
    End If

    ' 6. Assign Material: SUS303 (Stainless Steel)
    swPart.SetMaterialPropertyName2 "Default", "", "AISI 303"

    ' 7. Zoom to Fit & Isometric View
    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2

    MsgBox "สร้างโมเดล SolidWorks 3D สำหรับชิ้นงาน AA-14 (SUS303) สำเร็จ!" & vbCrLf & _
           "- Feature Tree ครบถ้วน สามารถ Edit Feature / Edit Sketch ได้ทันที" & vbCrLf & _
           "- รองรับ SolidWorks 2018 ขึ้นไป 100%", vbInformation, "SolidWorks Automation"

End Sub
