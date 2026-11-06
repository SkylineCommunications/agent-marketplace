namespace Skyline.DataMiner.Examples.SecureCoding
{
    using System;

    using Newtonsoft.Json;

    using Skyline.DataMiner.Utils.SecureCoding.SecureSerialization.Json.Newtonsoft;

    public sealed class DeviceStatus
    {
        [JsonProperty("name", Required = Required.Always)]
        public string Name { get; set; } = String.Empty;

        [JsonProperty("isOnline", Required = Required.Always)]
        public bool IsOnline { get; set; }
    }

    public static class DeviceStatusParser
    {
        public static DeviceStatus Parse(string rawJson)
        {
            if (String.IsNullOrWhiteSpace(rawJson))
            {
                throw new ArgumentException("A JSON response is required.", nameof(rawJson));
            }

            DeviceStatus result =
                SecureNewtonsoftDeserialization.DeserializeObject<DeviceStatus>(rawJson);

            if (result == null)
            {
                throw new JsonSerializationException("The response did not contain a device status.");
            }

            return result;
        }
    }
}
