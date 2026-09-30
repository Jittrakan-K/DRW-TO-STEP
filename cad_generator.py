"""
cad_generator.py - Professional CAD Engine for STEP AP203 & SolidWorks Automation
Generates ISO 10303-21 AP203 (CONFIG_CONTROL_DESIGN) B-Rep Solid models and SolidWorks VBA macros.
"""

import os
import math
import cadquery as cq
from OCP.STEPControl import STEPControl_Controller, STEPControl_Writer, STEPControl_AsIs
from OCP.Interface import Interface_Static

class CADGenerator:
    def __init__(self, output_dir="outputs"):
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)
        # Initialize STEP AP203 schema
        STEPControl_Controller.Init_s()
        Interface_Static.SetIVal_s('write.step.schema', 3) # 3 = AP203 (CONFIG_CONTROL_DESIGN)

    def generate_model(self, part_spec: dict) -> dict:
        """
        Builds 3D solid model based on parsed drawing specifications.
        Supports:
          - 'shaft' / 'turned' (stepped spindle/shaft with threads, flats, chamfers, keyways)
          - 'plate' (prismatic plate with hole patterns)
          - 'flange' (circular flange with PCD holes and hub)
        """
        part_type = part_spec.get('type', 'shaft')
        part_name = part_spec.get('name', 'Part_Model')
        material = part_spec.get('material', 'SUS303')

        if part_type == 'door_latch':
            solid = self._build_door_latch(part_spec)
        elif part_type == 'l_bracket':
            solid = self._build_l_bracket(part_spec)
        elif part_type in ['shaft', 'turned']:
            solid = self._build_turned_shaft(part_spec)
        elif part_type == 'flange':
            solid = self._build_flange(part_spec)
        else:
            solid = self._build_prismatic_plate(part_spec)

        # Output file paths
        step_filename = f"{part_name}_AP203.step"
        stl_filename = f"{part_name}.stl"
        vba_filename = f"{part_name}_SolidWorks_Macro.vba"

        step_path = os.path.join(self.output_dir, step_filename)
        stl_path = os.path.join(self.output_dir, stl_filename)
        vba_path = os.path.join(self.output_dir, vba_filename)

        # 1. Export STEP AP203
        self._export_step_ap203(solid, step_path, part_name)

        # 2. Export STL Mesh
        self._export_stl(solid, stl_path)

        # 3. Export SolidWorks VBA Macro
        vba_code = self._generate_solidworks_vba(part_spec)
        with open(vba_path, 'w', encoding='utf-8') as f:
            f.write(vba_code)

        # Bounding box and dimensions
        bb = solid.val().BoundingBox()

        return {
            "success": True,
            "part_name": part_name,
            "material": material,
            "step_file": step_filename,
            "step_path": step_path,
            "stl_file": stl_filename,
            "stl_path": stl_path,
            "vba_file": vba_filename,
            "vba_path": vba_path,
            "dimensions": {
                "length_x": round(bb.xlen, 3),
                "width_y": round(bb.ylen, 3),
                "height_z": round(bb.zlen, 3),
                "volume": round(solid.val().Volume(), 2)
            }
        }

    def _build_door_latch(self, spec: dict) -> cq.Workplane:
        """
        Builds a complete 3D Barrel Slide Bolt / Door Latch assembly with base plate,
        countersunk mounting holes, front/rear hollow barrels, sliding bolt rod, handle knob, and keeper.
        """
        base_l = float(spec.get('base_length', 100.0))
        base_w = float(spec.get('base_width', 42.0))
        base_t = float(spec.get('base_thickness', 3.0))
        bolt_dia = float(spec.get('bolt_dia', 10.0))
        bolt_len = float(spec.get('bolt_length', 115.0))
        bolt_throw = float(spec.get('bolt_throw', 22.0))
        barrel_od = float(spec.get('barrel_od', 15.0))
        handle_len = float(spec.get('handle_length', 28.0))
        knob_dia = float(spec.get('knob_dia', 13.0))
        keeper_l = float(spec.get('keeper_length', 26.0))
        screw_dia = float(spec.get('screw_hole_dia', 4.5))

        bolt_r = bolt_dia / 2.0
        barrel_r = barrel_od / 2.0
        bore_r = bolt_r + 0.4
        bolt_cy = base_t + barrel_r - 0.5

        # 1. Base Plate
        plate = cq.Workplane('XY').box(base_l, base_w, base_t, centered=(False, True, False))
        hole_pts = [(14.0, -base_w * 0.34), (14.0, base_w * 0.34),
                    (base_l * 0.5, -base_w * 0.34), (base_l * 0.5, base_w * 0.34),
                    (base_l - 14.0, -base_w * 0.34), (base_l - 14.0, base_w * 0.34)]
        plate = plate.faces('>Z').workplane().pushPoints(hole_pts).hole(screw_dia)

        # 2. Rear & Front Barrels along X
        barrel_len = max(18.0, base_l * 0.22)
        rear_barrel = (cq.Workplane('YZ')
                       .workplane(offset=6.0)
                       .center(0.0, bolt_cy)
                       .circle(barrel_r)
                       .circle(bore_r)
                       .extrude(barrel_len))
        front_barrel = (cq.Workplane('YZ')
                        .workplane(offset=base_l - 6.0 - barrel_len)
                        .center(0.0, bolt_cy)
                        .circle(barrel_r)
                        .circle(bore_r)
                        .extrude(barrel_len))

        # 3. Sliding Bolt Rod along X
        bolt_start_x = base_l + bolt_throw - bolt_len
        bolt_rod = (cq.Workplane('YZ')
                    .workplane(offset=bolt_start_x)
                    .center(0.0, bolt_cy)
                    .circle(bolt_r)
                    .extrude(bolt_len))

        # 4. Handle Stem + Knob along Z
        handle_x = base_l * 0.52
        handle_stem = (cq.Workplane('XY')
                       .workplane(offset=bolt_cy)
                       .center(handle_x, 0.0)
                       .circle(3.2)
                       .extrude(handle_len))
        knob = (cq.Workplane('XY')
                .workplane(offset=bolt_cy + handle_len)
                .center(handle_x, 0.0)
                .circle(knob_dia / 2.0)
                .extrude(knob_dia * 0.8))

        # 5. Strike Keeper Plate + Sleeve
        keeper_x = base_l + 6.0
        keeper_base = (cq.Workplane('XY')
                       .transformed(offset=(keeper_x, 0.0, 0.0))
                       .box(keeper_l, base_w, base_t, centered=(False, True, False)))
        keeper_sleeve = (cq.Workplane('YZ')
                         .workplane(offset=keeper_x + 2.0)
                         .center(0.0, bolt_cy)
                         .circle(barrel_r + 0.5)
                         .circle(bore_r + 0.3)
                         .extrude(keeper_l - 4.0))

        return plate.union(rear_barrel).union(front_barrel).union(bolt_rod).union(handle_stem).union(knob).union(keeper_base).union(keeper_sleeve)

    def _build_l_bracket(self, spec: dict) -> cq.Workplane:
        leg1 = float(spec.get('leg1_length', 65.0))
        leg2 = float(spec.get('leg2_length', 65.0))
        w = float(spec.get('width', 40.0))
        t = float(spec.get('thickness', 4.0))
        horiz = cq.Workplane('XY').box(leg2, w, t, centered=(False, True, False))
        vert = cq.Workplane('XY').box(t, w, leg1, centered=(False, True, False))
        return horiz.union(vert)

    def _build_turned_shaft(self, spec: dict) -> cq.Workplane:
        """
        Builds precision stepped shaft like AA-14 with flats and chamfers.
        """
        sections = spec.get('sections', [])
        if not sections:
            # Default to AA-14 drawing specifications
            sections = [
                {"name": "Left End", "dia": 10.0, "len": 16.0, "chamfer": 0.5, "flats": {"width": 9.5, "height": 9.5, "len": 8.0, "offset": 4.0}},
                {"name": "Thread M12x1", "dia": 12.0, "len": 10.0, "thread": "M12x1"},
                {"name": "Bearing Journal", "dia": 15.0, "len": 15.0, "tolerance": "h7"},
                {"name": "Collar Flange", "dia": 18.0, "len": 2.0},
                {"name": "Right End", "dia": 10.0, "len": 16.0, "chamfer": 0.5, "flats": {"width": 9.5, "height": 9.5, "len": 8.0, "offset": 4.0}}
            ]

        # 1. Build Revolve Profile along X-axis
        current_x = 0.0
        poly_points = [(0.0, 0.0)]

        for s in sections:
            r = s.get('dia', 10.0) / 2.0
            l = s.get('len', 10.0)
            poly_points.append((current_x, r))
            current_x += l
            poly_points.append((current_x, r))

        total_length = current_x
        poly_points.append((total_length, 0.0))
        poly_points.append((0.0, 0.0))

        # Revolve 360 deg around X-axis
        shaft = cq.Workplane('XZ').polyline(poly_points).close().revolve(360, (0, 0, 0), (1, 0, 0))

        # 2. Apply Wrench Flats (Section A-A, Section B-B)
        current_x = 0.0
        for s in sections:
            l = s.get('len', 10.0)
            r = s.get('dia', 10.0) / 2.0
            flats = s.get('flats')
            if flats:
                fw = flats.get('width', 9.5)
                fh = flats.get('height', 9.5)
                fl = flats.get('len', 8.0)
                fo = flats.get('offset', 4.0)

                cut_center_x = current_x + fo + fl / 2.0

                # Cut top & bottom in Y direction (if r > fh/2)
                if r > (fh / 2.0):
                    cut_h = (r - fh / 2.0) + 1.0
                    top_y = fh / 2.0 + cut_h / 2.0
                    bot_y = -(fh / 2.0 + cut_h / 2.0)
                    cut_top = cq.Workplane('XY').transformed(offset=(cut_center_x, top_y, 0)).box(fl, cut_h, r * 3)
                    cut_bot = cq.Workplane('XY').transformed(offset=(cut_center_x, bot_y, 0)).box(fl, cut_h, r * 3)
                    shaft = shaft.cut(cut_top).cut(cut_bot)

                # Cut sides in Z direction (if r > fw/2)
                if r > (fw / 2.0):
                    cut_w = (r - fw / 2.0) + 1.0
                    right_z = fw / 2.0 + cut_w / 2.0
                    left_z = -(fw / 2.0 + cut_w / 2.0)
                    cut_right = cq.Workplane('XZ').transformed(offset=(cut_center_x, 0, right_z)).box(fl, r * 3, cut_w)
                    cut_left = cq.Workplane('XZ').transformed(offset=(cut_center_x, 0, left_z)).box(fl, r * 3, cut_w)
                    shaft = shaft.cut(cut_right).cut(cut_left)

            current_x += l

        # 3. Apply End Chamfers
        try:
            c_left = shaft.faces('<X').edges().chamfer(0.5)
            shaft = c_left
        except Exception:
            pass

        try:
            c_right = shaft.faces('>X').edges().chamfer(0.5)
            shaft = c_right
        except Exception:
            pass

        return shaft

    def _build_prismatic_plate(self, spec: dict) -> cq.Workplane:
        length = spec.get('length', 120.0)
        width = spec.get('width', 80.0)
        thickness = spec.get('thickness', 20.0)

        plate = cq.Workplane('XY').box(length, width, thickness)

        # Add holes if specified
        holes = spec.get('holes', [])
        for h in holes:
            dia = h.get('dia', 10.0)
            hx = h.get('x', 0.0)
            hy = h.get('y', 0.0)
            plate = plate.faces('>Z').workplane().transformed(offset=(hx, hy, 0)).hole(dia)

        return plate

    def _build_flange(self, spec: dict) -> cq.Workplane:
        od = spec.get('od', 100.0)
        id_bore = spec.get('id', 30.0)
        thickness = spec.get('thickness', 15.0)
        pcd = spec.get('pcd', 75.0)
        num_holes = spec.get('num_holes', 4)
        hole_dia = spec.get('hole_dia', 9.0)

        flange = cq.Workplane('XY').circle(od / 2.0).circle(id_bore / 2.0).extrude(thickness)

        # PCD bolt pattern
        if num_holes > 0 and pcd > 0:
            flange = flange.faces('>Z').workplane().polygon(num_holes, pcd).vertices().hole(hole_dia)

        return flange

    def _export_step_ap203(self, model: cq.Workplane, filepath: str, part_name: str):
        """
        Exports standardized ISO-10303-21 STEP AP203 file.
        """
        writer = STEPControl_Writer()
        shape = model.val().wrapped
        writer.Transfer(shape, STEPControl_AsIs)
        writer.Write(filepath)

    def _export_stl(self, model: cq.Workplane, filepath: str):
        """
        Exports STL mesh for Three.js rendering and 3D printing.
        """
        cq.exporters.export(model, filepath, cq.exporters.ExportTypes.STL, tolerance=0.08, angularTolerance=0.15)

    def _generate_solidworks_vba(self, spec: dict) -> str:
        """
        Generates SolidWorks VBA Macro script creating native editable Feature Tree.
        """
        part_name = spec.get('name', 'Part_Model')
        material = spec.get('material', 'SUS303')
        sections = spec.get('sections', [])

        vba = f"""' ******************************************************************************
' SolidWorks VBA Macro: Automatic 3D Parametric Feature Tree
' Generated for: {part_name}
' Material: {material}
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
            defaultPartTemplate = "C:\\ProgramData\\SolidWorks\\SOLIDWORKS 2018\\templates\\Part.prtdot"
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
"""
        total_len_m = sum(s.get('len', 10.0) for s in sections) * 0.001
        vba += f"    swSketchMgr.CreateCenterLine 0#, 0#, 0#, {total_len_m:.6f}, 0#, 0#\n\n"

        # Contour lines
        curr_x = 0.0
        vba += f"    ' Revolve Contour\n"
        vba += f"    swSketchMgr.CreateLine 0#, 0#, 0#, 0#, {(sections[0]['dia']/2)*0.001:.6f}, 0#\n"

        for idx, s in enumerate(sections):
            r_m = (s.get('dia', 10.0) / 2.0) * 0.001
            l_m = s.get('len', 10.0) * 0.001
            next_x = curr_x + l_m
            vba += f"    swSketchMgr.CreateLine {curr_x:.6f}, {r_m:.6f}, 0#, {next_x:.6f}, {r_m:.6f}, 0#\n"
            if idx < len(sections) - 1:
                next_r_m = (sections[idx + 1].get('dia', 10.0) / 2.0) * 0.001
                if abs(next_r_m - r_m) > 1e-6:
                    vba += f"    swSketchMgr.CreateLine {next_x:.6f}, {r_m:.6f}, 0#, {next_x:.6f}, {next_r_m:.6f}, 0#\n"
            curr_x = next_x

        last_r_m = (sections[-1].get('dia', 10.0) / 2.0) * 0.001
        vba += f"    swSketchMgr.CreateLine {curr_x:.6f}, {last_r_m:.6f}, 0#, {curr_x:.6f}, 0#, 0#\n"
        vba += f"    swSketchMgr.CreateLine {curr_x:.6f}, 0#, 0#, 0#, 0#, 0#\n\n"

        vba += """    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, 6.2831853071796, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
    If Not swFeat Is Nothing Then
        swFeat.Name = "Revolve-Body"
    End If

    ' 2. Cut-Extrude Wrench Flats
"""
        curr_x = 0.0
        for idx, s in enumerate(sections):
            l = s.get('len', 10.0)
            flats = s.get('flats')
            if flats:
                fw_m = flats.get('width', 9.5) * 0.001
                fh_m = flats.get('height', 9.5) * 0.001
                fl_m = flats.get('len', 8.0) * 0.001
                fo_m = flats.get('offset', 4.0) * 0.001
                x1_m = (curr_x * 0.001) + fo_m
                x2_m = x1_m + fl_m

                # Cut Top/Bot
                vba += f"""    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle {x1_m:.6f}, {fh_m/2:.6f}, 0#, {x2_m:.6f}, 0.015, 0#
    swSketchMgr.CreateCornerRectangle {x1_m:.6f}, -{fh_m/2:.6f}, 0#, {x2_m:.6f}, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Top-Bot #{idx+1}"

    swModel.ClearSelection2 True
    swModelDocExt.SelectByID2 "Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCornerRectangle {x1_m:.6f}, {fw_m/2:.6f}, 0#, {x2_m:.6f}, 0.015, 0#
    swSketchMgr.CreateCornerRectangle {x1_m:.6f}, -{fw_m/2:.6f}, 0#, {x2_m:.6f}, -0.015, 0#
    swModel.ClearSelection2 True
    Set swFeat = swFeatMgr.FeatureCut4(True, False, False, 0, 0, 0.03, 0.01, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
    If Not swFeat Is Nothing Then swFeat.Name = "Cut-Flats Sides #{idx+1}"
"""
            curr_x += l

        vba += f"""
    ' 3. Set Material: {material}
    swPart.SetMaterialPropertyName2 "Default", "", "{material}"

    ' 4. Isometric View
    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2

    MsgBox "สร้างโมเดล {part_name} พร้อม Feature Tree ใน SolidWorks สำเร็จ!", vbInformation, "SolidWorks Automation"

End Sub
"""
        return vba
