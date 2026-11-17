using System;
using System.Collections.Generic;

using Skyline.DataMiner.Scripting;
using Skyline.DataMiner.Utils.Protocol.Extension;

/// <summary>
/// Demonstrates the QAction API surfaces without a generated QAction helper.
/// </summary>
public static class QAction
{
    private const int DevicesTablePid = 1000;
    private const int DeviceNameColumnPid = 1002;
    private const uint DeviceKeyColumnIdx = 0;
    private const uint DeviceNameColumnIdx = 1;

    /// <summary>
    /// Exercises built-in table methods and optional package extension methods.
    /// </summary>
    /// <param name="protocol">Link with the SLProtocol process.</param>
    public static void Run(SLProtocol protocol)
    {
        try
        {
            var rows = new List<object[]>
            {
                new object[] { "device-1", "Primary" },
            };

            protocol.FillArray(DevicesTablePid, rows, NotifyProtocol.SaveOption.Full);
            protocol.FillArrayNoDelete(
                DevicesTablePid,
                new object[] { new object[] { "device-1" }, new object[] { "Primary" } });
            protocol.FillArrayWithColumn(
                DevicesTablePid,
                DeviceNameColumnPid,
                new object[] { "device-1" },
                new object[] { "Updated" });
            protocol.SetRow(DevicesTablePid, "device-1", new object[] { "device-1", "Updated" });
            protocol.AddRow(DevicesTablePid, new object[] { "device-2", "Secondary" });
            protocol.DeleteRow(DevicesTablePid, "device-2");

            _ = protocol.GetColumns(
                DevicesTablePid,
                new uint[] { DeviceKeyColumnIdx, DeviceNameColumnIdx });

            var columnsToSet = new Dictionary<int, List<object>>
            {
                { DevicesTablePid, new List<object> { "device-1" } },
                { DeviceNameColumnPid, new List<object> { "Primary" } },
            };

            protocol.SetColumns(columnsToSet);
        }
        catch (Exception ex)
        {
            protocol.Log(
                $"QA{protocol.QActionID}|Run|API example failed: {ex}",
                LogType.Error,
                LogLevel.NoLogging);
        }
    }
}
