##Input Clock
set_property PACKAGE_PIN E3 [get_ports SYSCLK_100]
set_property IOSTANDARD LVCMOS33 [get_ports SYSCLK_100]


##RS232 pins - Wired (comment out for bluetooth) D4 TX C4 RX (usb) G16 TX H14 RX (bt)
set_property -dict { PACKAGE_PIN D4	IOSTANDARD LVCMOS33 } [get_ports RS232_TX]
set_property -dict { PACKAGE_PIN C4	IOSTANDARD LVCMOS33 } [get_ports RS232_RX]
##set_property -dict { PACKAGE_PIN G16	IOSTANDARD LVCMOS33 } [get_ports RS232_TX]
##set_property -dict { PACKAGE_PIN H14	IOSTANDARD LVCMOS33 } [get_ports RS232_RX]
##set_property -dict { PACKAGE_PIN D3	IOSTANDARD LVCMOS33 } [get_ports USB_CTS]
##set_property -dict { PACKAGE_PIN E5	IOSTANDARD LVCMOS33 } [get_ports USB_RTS]


##Edit bus width for memory config
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]


##Audio
set_property -dict { PACKAGE_PIN A11	IOSTANDARD LVCMOS33 } [get_ports audio_out]

##LEDs
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[0] }];
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[1] }];
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[2] }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[3] }];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[4] }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[5] }];
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[6] }];
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[7] }];
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[8] }];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[9] }];
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[10] }];
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[11] }];
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[12] }];
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[13] }];
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[14] }];
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33  SLEW SLOW } [get_ports { LED_ID[15] }];


##RGB LEDs
set_property -dict { PACKAGE_PIN N16	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_0[2] }]
set_property -dict { PACKAGE_PIN R11	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_0[1] }]
set_property -dict { PACKAGE_PIN G14	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_0[0] }]

set_property -dict { PACKAGE_PIN N15	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_1[2] }]
set_property -dict { PACKAGE_PIN M16	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_1[1] }]
set_property -dict { PACKAGE_PIN R12	IOSTANDARD LVCMOS33	SLEW SLOW } [get_ports { RGB_1[0] }]


##7 segment display
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { seg[7] }]; #IO_L24N_T3_A00_D16_14 Sch=ca
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]; #IO_25_14 Sch=cb
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]; #IO_25_15 Sch=cc
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]; #IO_L17P_T2_A26_15 Sch=cd
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]; #IO_L13P_T2_MRCC_14 Sch=ce
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]; #IO_L19P_T3_A10_D26_14 Sch=cf
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]; #IO_L4P_T0_D04_14 Sch=cg
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]; #IO_L19N_T3_A21_VREF_15 Sch=dp
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { seg_s[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { seg_s[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { seg_s[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { seg_s[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { seg_s[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { seg_s[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { seg_s[6] }]; #IO_L23P_T3_35 Sch=an[6]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { seg_s[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]


##Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { switch_0 }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { switch_1 }];
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { switch_2 }];
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { switch_3 }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { switch_4 }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { switch_5 }];
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { switch_6 }];
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { switch_7 }];

##Buttons
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { btn_m }];