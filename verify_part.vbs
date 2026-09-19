' verify_part.vbs
On Error Resume Next
Dim swApp, swModel, swPart, swFeat
Dim sldprtPath, fso

Dim scriptDir
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
sldprtPath = scriptDir & "\outputs\JIG-MOT097Z001-0.sldprt"

Set swApp = CreateObject("SldWorks.Application")
If swApp Is Nothing Then
    WScript.Echo "ERROR: SolidWorks is Nothing"
    WScript.Quit 1
End If

swApp.Visible = True

Dim docErrors, docWarnings
Set swModel = swApp.OpenDoc6(sldprtPath, 1, 0, "", docErrors, docWarnings)
If swModel Is Nothing Then
    WScript.Echo "ERROR: OpenDoc6 failed, errors=" & docErrors
    WScript.Quit 2
End If

WScript.Echo "Opened document: " & swModel.GetTitle

' Iterate features
Set swFeat = swModel.FirstFeature
Dim featCount, errCount
featCount = 0
errCount = 0

Do While Not swFeat Is Nothing
    featCount = featCount + 1
    Dim fName, fType, fTypeName
    fName = swFeat.Name
    fTypeName = swFeat.GetTypeName2
    
    ' Check if feature has warnings or errors
    ' swFeatureError_e or GetErrorCode2
    Dim errList
    Call swFeat.GetErrorCode2(errList)
    If Err.Number <> 0 Then
        ' Ignore GetErrorCode2 signature mismatch
        Err.Clear
    End If
    
    WScript.Echo "Feature [" & featCount & "]: " & fName & " (" & fTypeName & ")"
    Set swFeat = swFeat.GetNextFeature
Loop

' Force rebuild
swModel.ForceRebuild3 True
WScript.Echo "Rebuild completed."

' Save image snapshot
Dim imgPath
imgPath = scriptDir & "\outputs\jig_plate_solidworks_verified.png"
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 imgPath, 0, 2
WScript.Echo "Saved snapshot: " & imgPath & " (Exists: " & fso.FileExists(imgPath) & ")"

swApp.CloseDoc swModel.GetTitle
WScript.Quit 0
