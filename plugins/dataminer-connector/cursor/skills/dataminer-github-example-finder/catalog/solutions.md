# Solution & Best-Practice Examples (SLC-S-*)

## Repository

Name: SLC-S-Example_InterAppCalls

GitHub:
https://github.com/SkylineCommunications/SLC-S-Example_InterAppCalls

Category:
Best-Practice Implementation

Tags:
- solution
- interapp
- nuget
- connector-api
- csharp

Status:
Approved

Owner:
Skyline Communications

Description:
Example solution showing how to create a ConnectorAPI NuGet package using the Skyline.DataMiner.Core.InterApp library. Demonstrates best practices for packaging a connector's public API so Automation Scripts can call it without directly depending on the InterApp library.

Why Use It:
Best-practice reference for ConnectorAPI NuGet authoring — how to expose message types without leaking InterApp library types to consumers, preventing versioning issues. Completes the InterApp pattern trilogy alongside the connector and AS examples.

Typical Use Cases:
- Creating a reusable NuGet package that encapsulates a connector's InterApp message API
- Reference for connector API packaging and versioning best practices

Related Repositories: SLC-C-Example_InterAppCalls, SLC-AS-Example_InterAppCalls
