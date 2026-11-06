package blueprint

_snip: {
	mqtt: "mqtt"

	input: {
		default: []
		selector: action: {}
	}
}

// ——————————————————————————————————————————————————————————————————————————————————————————————————
Blueprint: {
	deviceName: "Sonoff Button SNZB-01P"
	domain:     "mqtt"

	input: {
		z2mDevice: {
			key:         "z2m_device"
			description: "The \(deviceName) device from Zigbee2MQTT"
			inputs: {
				single_press: {
					key:   "single_press"
					zid:   "single"
					label: "SINGLE press"
				}
				double_press: {
					key:   "double_press"
					zid:   "double"
					label: "DOUBLE press"
				}
				long_press: {
					key:   "long_press"
					zid:   "long"
					label: "LONG press"
				}
			}
		}
	}
}

// ——————————————————————————————————————————————————————————————————————————————————————————————————
files: [
	{
		name: "sonoff-snzb-01p-button.yml"
		contents: {
			_b:   Blueprint
			_z2d: Blueprint.input.z2mDevice

			mode:         "restart"
			max_exceeded: "silent"

			blueprint: {
				name:   _b.deviceName
				domain: "automation"
				author: "Brian Kenkel"
				// description:
				input: {
					(_b.input.z2mDevice.key): {
						name:        "Z2M Device"
						description: _b.input.z2mDevice.description
						selector: device: integration: _b.domain
					}

					for _, input in _z2d.inputs {
						(input.key): {
							name: input.label
							default: []
							selector: action: {}
						}
					}
				}
			}

			triggers: [
				for _, input in _z2d.inputs {
					{
						trigger:   "device"
						domain:    "mqtt"
						type:      "action"
						device_id: _z2d.key @yaml(,tag="!input")
						subtype:   input.zid
						id:        input.key
					}
				}
			]

			conditions: []

			actions: [{
				choose: [for _, i in _z2d.inputs {
					conditions: [{condition: "trigger", id: i.key}]
					sequence: i.key @yaml(,tag="!input")
				}]
			}]
		}
	}
]
