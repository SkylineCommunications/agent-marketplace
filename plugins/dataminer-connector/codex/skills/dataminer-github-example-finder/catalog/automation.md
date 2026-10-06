# Automation Script Examples (SLC-AS-*)

## Repository

Name: SLC-AS-SetParameter

GitHub:
https://github.com/SkylineCommunications/SLC-AS-SetParameter

Category:
Example Repository

Tags:
- automation
- engine-api
- csharp

Status:
Approved
Recommendation: Eligible
Verified Commit: b9e75f8ae5334ca5c98fc7c7fcab423a36e7e78f
Verified Date: 2026-09-16
Default Branch: main
Compatibility: SDK Automation script; MinimumRequiredDmVersion 10.3.0.0 - 12752; Dev.Automation 10.3.0.25; verify the target before reuse.
Package Baseline: Skyline.DataMiner.Dev.Automation 10.3.0.25; Skyline.DataMiner.Utils.SecureCoding.Analyzers 2.2.3.
Modeled Pattern: Non-interactive Run/RunSafe, script-parameter normalization, element resolution, and parameter writes.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
A minimal, official Automation script that reads script parameters, resolves an element (by name or DataMinerID/ElementID), and sets a parameter value. SDK-style solution with CatalogInformation (manifest.yml + README) and a Quality-Gate workflow.

Why Use It:
The cleanest reference for the canonical non-interactive script shape — Run/RunSafe structure, abort-exception handling, script-parameter input normalization, robust element resolution, and ExitFail/ExitSuccess.

Typical Use Cases:
- Starting point for a new non-interactive Automation script
- Reference for reading script parameters and acting on an element

Related Repositories: SLC-AS-Example_InteractiveAutomationScriptToolkit

---

## Repository

Name: SLC-AS-Example_InteractiveAutomationScriptToolkit

GitHub:
https://github.com/SkylineCommunications/SLC-AS-Example_InteractiveAutomationScriptToolkit

Category:
Example Repository

Tags:
- automation
- interactive
- ias-toolkit
- ui

Status:
Approved
Recommendation: Eligible
Verified Commit: a6208b151d9464dd2649bdbd37a68f7d895def79
Verified Date: 2026-09-16
Default Branch: main
Compatibility: IAS Toolkit 7.0.5 + Dev.Automation 10.3.7; verify the Toolkit lifecycle against the requested target before reuse.
Package Baseline: Skyline.DataMiner.Dev.Automation 10.3.7; Skyline.DataMiner.Utils.InteractiveAutomationScriptToolkit 7.0.5; Skyline.DataMiner.Utils.SecureCoding.Analyzers 2.2.1.
Modeled Pattern: IAS widgets, InteractiveController, Dialog layout, navigation, and MVP examples.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
The official Interactive Automation Script (IAS) Toolkit example collection — one script per component (CheckBoxList, DropDownFilter, DynamicButtonList, DynamicSections (MVP), HideUI, LazyLoadDropDown, ModelViewPresenter) using Skyline.DataMiner.Utils.InteractiveAutomationScript.

Why Use It:
Canonical patterns for building operator-facing UIs: InteractiveController, Dialog subclasses, widgets, AddWidget grid layout, event-driven navigation, and the Model-View-Presenter approach for complex dialogs.

Typical Use Cases:
- Building wizards, forms, or dashboards as interactive automation scripts
- Reference for any specific IAS widget or layout pattern

Related Repositories: SLC-AS-SetParameter

---

## Repository

Name: SLC-AS-Example_InterAppCalls

GitHub:
https://github.com/SkylineCommunications/SLC-AS-Example_InterAppCalls

Category:
Example Repository

Tags:
- automation
- interapp
- interapp-calls
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 75136433df78ac1dddf95ec3d2299b4981594990
Verified Date: 2026-09-16
Default Branch: main
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: Automation-side InterApp call pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example Automation Script that uses the InterApp NuGet package (from SLC-S-Example_InterAppCalls) to make InterApp calls to a connector element. Shows the Automation Script side of the complete InterApp pattern.

Why Use It:
Reference for how to invoke InterApp messages from an Automation Script — constructing message objects from the connector's NuGet API, sending to an element, and handling the response.

Typical Use Cases:
- Automation scripts that orchestrate or control elements via InterApp
- Learning the Automation Script side of the full InterApp trilogy

Related Repositories: SLC-C-Example_InterAppCalls, SLC-S-Example_InterAppCalls

---

## Repository

Name: SLC-AS-Example_PLM_MaskAlarms

GitHub:
https://github.com/SkylineCommunications/SLC-AS-Example_PLM_MaskAlarms

Category:
Example Repository

Tags:
- automation
- alarms
- masking
- plm
- planned-maintenance
- csharp

Status:
Approved
Recommendation: Conditional
Verified Commit: 46b87e393c890b717fdaa3831685d1aec603f177
Verified Date: 2026-09-16
Default Branch: main
Compatibility: Compatibility not verified; target/package references must be checked before reuse.
Package Baseline: Not verified — inspect project files at the pinned commit.
Modeled Pattern: PLM alarm mask/unmask Automation pattern described by the catalog entry; verify the source before reuse.
Legacy Behavior: None observed; verify before extending.

Owner:
Skyline Communications

Description:
Example Automation Script that masks and unmasks correlation base alarms based on active PLM (Planned Maintenance) activities for the same entity. Demonstrates integrating with the DataMiner PLM module from an Automation Script.

Why Use It:
Reference for alarm masking/unmasking logic in Automation Scripts and for reading PLM activity data to make runtime decisions.

Typical Use Cases:
- Automating alarm suppression during planned maintenance windows
- Reference for the PLM API and alarm mask/unmask patterns

Related Repositories: SLC-AS-SetParameter
