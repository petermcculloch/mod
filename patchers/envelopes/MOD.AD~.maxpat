{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 7,
			"minor" : 3,
			"revision" : 1,
			"architecture" : "x86",
			"modernui" : 1
		}
,
		"rect" : [ 84.0, 128.0, 1161.0, 568.0 ],
		"bglocked" : 0,
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 1,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 1,
		"objectsnaponopen" : 1,
		"statusbarvisible" : 2,
		"toolbarvisible" : 1,
		"lefttoolbarpinned" : 0,
		"toptoolbarpinned" : 0,
		"righttoolbarpinned" : 0,
		"bottomtoolbarpinned" : 0,
		"toolbars_unpinned_last_save" : 0,
		"tallnewobj" : 0,
		"boxanimatetime" : 200,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"description" : "",
		"digest" : "",
		"tags" : "",
		"style" : "",
		"subpatcher_template" : "",
		"boxes" : [ 			{
				"box" : 				{
					"id" : "obj-12",
					"maxclass" : "newobj",
					"numinlets" : 3,
					"numoutlets" : 3,
					"outlettype" : [ "signal", "signal", "signal" ],
					"patcher" : 					{
						"fileversion" : 1,
						"appversion" : 						{
							"major" : 7,
							"minor" : 3,
							"revision" : 1,
							"architecture" : "x86",
							"modernui" : 1
						}
,
						"rect" : [ 674.0, 78.0, 1212.0, 898.0 ],
						"editing_bgcolor" : [ 0.9, 0.9, 0.9, 1.0 ],
						"bglocked" : 0,
						"openinpresentation" : 0,
						"default_fontsize" : 12.0,
						"default_fontface" : 0,
						"default_fontname" : "Arial",
						"gridonopen" : 1,
						"gridsize" : [ 15.0, 15.0 ],
						"gridsnaponopen" : 1,
						"objectsnaponopen" : 1,
						"statusbarvisible" : 2,
						"toolbarvisible" : 1,
						"lefttoolbarpinned" : 0,
						"toptoolbarpinned" : 0,
						"righttoolbarpinned" : 0,
						"bottomtoolbarpinned" : 0,
						"toolbars_unpinned_last_save" : 0,
						"tallnewobj" : 0,
						"boxanimatetime" : 200,
						"enablehscroll" : 1,
						"enablevscroll" : 1,
						"devicewidth" : 0.0,
						"description" : "",
						"digest" : "",
						"tags" : "",
						"style" : "",
						"subpatcher_template" : "",
						"boxes" : [ 							{
								"box" : 								{
									"code" : "// From MOD.Lib~\nHistory atk_coeff(0.001);\nHistory dcy_coeff(0.0001);\nHistory atk_dur(1000);\nHistory dcy_dur(10000);\nHistory rc_atk_coeff(0.999);\nHistory rc_dcy_coeff(0.9999);\nHistory reattack_coeff(0.01);\nHistory prev_in2(1000.),prev_in3(10000.);\nHistory x(0);\nHistory x_at_attack(0);\nHistory do_attack(0);\nHistory do_reattack(0);\nHistory recalc_coeffs(0);\nHistory vel(1);\nParam constant_time(1);\nParam legato(0);\nParam reattack_time(1200);\nParam oneshot(0);\nParam gate_output(0);\nParam linear(1);\nParam loop(0);\nHistory prev_linear(1);\nHistory eoa_k(9223372036854775800); // Seconds until gun control laws are passed\nHistory eod_k(9223372036854775800); // \nHistory eoa_out(0);\nHistory eod_out(0);\n\n/* Constants\n *  \n *  After 3 iterations of the RC accumulator, the accumulator will be ~95% of the way there.  \n *  By aiming for a target that's ~5% past, we get there right on time.  \n *  (The bottom part of the fraction is the ~95% part)\n */\nhigh_target = 1./((1.-1./e) + (1.-1./e)/e + (1.-1./e)/(e*e));  // Going up...\nlow_target = 1.-high_target;                                    // Going down...\n\nBIG_NUMBER = 9223372036854775800; // Really big number to use as an upper limit for timing accumulators\npulse_dur = mstosamps(10);\n\nlinear_change = linear != prev_linear;  // Do we need to recalculate?\nrecalc_coeffs=1;\nif (recalc_coeffs || prev_in2 != in2 || linear_change) {\n\tatk_dur = max(mstosamps(in2),1);\n\tif (linear) {\n\t\tif (constant_time) {\n\t\t\tatk_coeff = (vel-x_at_attack)/atk_dur;\n\t\t} else {\n\t\t\tatk_coeff = vel/atk_dur;\n\t\t}\n\t} else {\n\t\t// RC Coeffs\n\t\tinv_atk = 1./atk_dur;\n\t\tif (constant_time) {\n\t\t\trc_atk_coeff = 1.- exp(3. * inv_atk * (-1.+min(x_at_attack*legato, 0.99)));\n\t\t} else {\n\t\t\trc_atk_coeff = 1.-(exp(-3. * inv_atk));\n\t\t}\n\t\n\t}\n\tpulse_dur = min(mstosamps(10),(atk_dur+dcy_dur)*0.5);\n\trecalc_coeffs = 0;\n}\n\nif (prev_in3 != in3 || linear_change) {\n\tdcy_dur = max(mstosamps(in3),1);\n\tif (linear) {\n\t\tdcy_coeff = 1./dcy_dur;\n\t} else {\n\t\trc_dcy_coeff = 1.-(exp(-3./dcy_dur));\n\t}\n\tpulse_dur = min(mstosamps(5),(atk_dur+dcy_dur)*0.5);\n\n}\n\n// single sample pulse\nif (in1 || loop && x == 0) {\n\t// If not in oneshot mode, or we're already back at 0, allow attack.\n\tif (x == 0 || !oneshot) {\t\n\t\tvel = max(in1,x);\n\t\tif (x == 0 || legato) {\n\t\t\t// Straight forward case\n\t\t\tx_at_attack = x;\n\t\t\tdo_attack = 1;\t\n\t\t\tdo_reattack = 0;\n\t\t\trecalc_coeffs = 1;\n\t\t} else {\n\t\t\tx_at_attack = 0;\n\t\t\tdo_attack = 1;\n\t\t\tdo_reattack = 1;\n\t\t\tif (constant_time) {\n\t\t\t\treattack_coeff = (max(x,0.0001))/reattack_time;\n\t\t\t} else {\n\t\t\t\treattack_coeff = vel/reattack_time;\t\n\t\t\t}\n\t\t\t// Do not reattack slower than twice the decay.\n\t\t\treattack_coeff = max(reattack_coeff,dcy_coeff*2);\n\t\t\trecalc_coeffs = 1; // Force recalculation\n\t\t}\n\t}\n}\n\n\nprev_x = x;\t // Store so we can see if we've hit the end.\n\n// Increment x as needed\nif (linear) {\n\tx += (!do_reattack*(do_attack * atk_coeff - !do_attack * dcy_coeff)) - (do_reattack * reattack_coeff);\n} else {\n\tx +=  (!do_reattack*(do_attack * rc_atk_coeff*(high_target-x)) + (!do_attack * rc_dcy_coeff)*(low_target - x)) \n\t\t  - (do_reattack * reattack_coeff);\n}\n\nx = clip(x,0,max(x,vel));\ndo_reattack = (do_reattack && x != 0); // reset when x == 0\nprev_do_atk = do_attack;\ndo_attack = do_attack && x < vel;        // switch to decay when reaching 1\n\neoa_k = prev_do_atk && !do_attack ? 0 : clip(eoa_k+1,0,BIG_NUMBER);\neod_k = (prev_x > 0. && x == 0.) ? 0 : clip(eod_k+1,0,BIG_NUMBER);\nif (gate_output) {\n\teoa_out = !do_attack;\t\t\t   // goes low at start of attack, high at beginning of decay\n\teod_out = !xor(x > 0,in1 || do_attack);          // goes low at start of attack, high at end of decay or next attack.\n} else {\n\teoa_out = eoa_k < 1; // pulse_dur;\n\teod_out = eod_k < 1; // pulse_dur;\n}\nprev_in2 = in2;\nprev_in3 = in3;\nprev_linear = linear;\n\nout1 = x;\nout2 = eoa_out;\nout3 = eod_out;",
									"fontface" : 0,
									"fontname" : "Arial",
									"fontsize" : 12.0,
									"id" : "obj-3",
									"maxclass" : "codebox",
									"numinlets" : 3,
									"numoutlets" : 3,
									"outlettype" : [ "", "", "" ],
									"patching_rect" : [ 860.0, 87.0, 200.0, 200.0 ],
									"style" : ""
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-9",
									"maxclass" : "newobj",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 772.0, 14.0, 75.0, 22.0 ],
									"style" : "",
									"text" : "in 3 @min 0"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-7",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 0,
									"patching_rect" : [ 772.0, 599.0, 37.0, 22.0 ],
									"style" : "",
									"text" : "out 3"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-6",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 0,
									"patching_rect" : [ 396.0, 599.0, 37.0, 22.0 ],
									"style" : "",
									"text" : "out 2"
								}

							}
, 							{
								"box" : 								{
									"code" : "Param loop (0); \r\nParam retrig (5);\r\nParam mode (1);   // 0 = retrig, 1 = legato, 2 = wait\r\nParam constant_rate (0);\r\n\r\nHistory ak (0);\r\nHistory dk (0);\r\nHistory akInc (1. / 22050.);\r\nHistory dkInc (1. / 22050.);\r\nHistory atk_dur (22050);\r\nHistory dcy_dur (22050);\r\nHistory lin_atk_coeff (1. / 22050);\r\nHistory lin_dcy_coeff (1. / 22050);\r\nHistory lin_trg_coeff (1. / 220.5);\r\nHistory eoa (0);\r\nHistory eod (1);\r\n\r\nHistory targetX (1.);\r\nHistory x (0);\r\nHistory stage (0);\r\nHistory prev_trig (0);\r\nHistory prev_mode(1);\r\nHistory prev_in2 (-1);\r\nHistory prev_in3 (-1);\r\n\r\nMIN_ATTACK_TIME = 1;\r\nMIN_DECAY_TIME = 1;\r\nTOTAL_AD_TIME = 2;\r\n\r\natk_dur = mstosamps(in2);\r\ndcy_dur = mstosamps(in3);\r\n\r\ntotal_dur = max (atk_dur + dcy_dur, TOTAL_AD_TIME);\r\n// Steals from attack or decay as necessary to maintain total duration.\r\natk_dur = total_dur - dcy_dur <= MIN_ATTACK_TIME ? MIN_ATTACK_TIME : total_dur - max(dcy_dur, MIN_DECAY_TIME);\r\ndcy_dur = total_dur - atk_dur;\r\n\r\n\r\nlin_atk_coeff = targetX / atk_dur;\r\nlin_dcy_coeff = targetX / dcy_dur;\r\n\r\nif (prev_mode != mode)\r\n{\r\n\takInc = lin_atk_coeff;\r\n\tdkInc = lin_dcy_coeff;\r\n}\r\n\r\n\r\nif ((in1 && (prev_trig == 0) && (stage >= 0)) || (stage == 2) && (loop == 1))\r\n{\r\n    if (mode <= 0)  // Retrigger mode\r\n    {\r\n\t    if (x > 0) \r\n\t    {\r\n\t\t\t// Start from position relative to coefficient\r\n\t\t\tif (stage == 0)\r\n\t\t\t{\r\n\t\t\t\tak = x % lin_atk_coeff; \r\n\t\t\t}\r\n\t\t\telse if (stage == 1)\r\n\t\t\t{\r\n\t\t\t\tdk = x % lin_dcy_coeff;\r\n\t\t\t}\r\n\t\t\t\r\n\t        // Decay at current rate if it's faster than retrig rate (5 ms default)\r\n\t        lin_trg_coeff = max (lin_dcy_coeff, x / max(1, mstosamps (retrig))); \r\n            stage = -1;\r\n\t\t}\r\n      \telse\r\n\t\t{\r\n\t    \tstage = 0;\r\n    \t}\r\n\t\takInc = lin_atk_coeff;\r\n\t\tdkInc = lin_dcy_coeff;\r\n\t}\r\n\telse if (mode <= 1) \r\n\t{\r\n\t\tif (stage == 0)\r\n\t\t{\r\n\t\t\takInc = lin_atk_coeff;\r\n\t\t}\r\n\t\telse if (stage == 1)\r\n\t\t{\r\n\t\t\tak = x;\r\n\t\t\tdk = dk % dkInc;\r\n\t\t\takInc = constant_rate ? akInc : max(0, targetX - x) / atk_dur;\r\n\t\t\tstage = 0;\r\n\t\t}\r\n\t\telse \r\n\t\t{\r\n\t\t\t// Reset stage and coefficient.  (Do not modify ak!)\r\n\t\t\tstage = 0;\r\n\t\t\takInc = lin_atk_coeff;\r\n\t\t}\r\n\t\t\r\n\t\tdkInc = lin_dcy_coeff;\r\n\r\n\t}\r\n\telse  // Wait mode (does not affect looping)\r\n\t{\r\n\t\tif (x <= 0) \r\n\t    {\r\n\t\t\t// Start from position relative to coefficient\r\n\t\t\tif (stage == 0)\r\n\t\t\t{\r\n\t\t\t\tak = x % lin_atk_coeff; \r\n\t\t\t}\r\n\t\t\telse if (stage == 1)\r\n\t\t\t{\r\n\t\t\t\tdk = x % lin_dcy_coeff;\r\n\t\t\t}\r\n\t\t\t\r\n\t        // Decay at current rate if it's faster than retrig rate (5 ms default)\r\n\t        lin_trg_coeff = max (lin_dcy_coeff, x / max(1, mstosamps (retrig))); \r\n            stage = 0;\r\n\t\t} \r\n\t\telse if (!in1 && loop) // If not triggered, but in loop mode...\r\n\t\t{\r\n\t\t\tstage = 0;   \r\n\t\t}\r\n\t\takInc = lin_atk_coeff;\r\n\t\tdkInc = lin_dcy_coeff;\r\n\t}\r\n\t\r\n}\r\n\r\n\r\n\r\nif (stage < 0)\r\n{\r\n\tx -= lin_trg_coeff;\r\n\tstage += (x <= 0.);\r\n\tx = (x <= 0) ? ak : x;\r\n} \r\nelse if (stage == 0)\r\n{\r\n\tak += akInc;\r\n\tstage += (ak >= targetX); // If over...\r\n\tx = ak;\t\t\r\n\tak = ak % targetX;\t\r\n}\r\nelse if (stage == 1)\r\n{\r\n\tdk += dkInc;\r\n\tstage = stage + (dk >= 1); \r\n\tx = 1 - dk;\r\n\tdk = dk % 1;\r\n}\r\nelse\r\n{\r\n\tx = 0;\r\n\tstage = 2;\r\n}\r\n\r\n\r\n\r\nprev_trig = in1;\r\nprev_mode = mode;\r\nprev_in2 = in2;\r\nprev_in3 = in3;\r\n\r\neoa = (stage == 1);\r\neod = (stage  != 1);\r\n\r\nout1 = max(0, x);\r\nout2 = eoa; \r\nout3 = eod; ",
									"fontface" : 0,
									"fontname" : "Arial",
									"fontsize" : 12.0,
									"id" : "obj-5",
									"maxclass" : "codebox",
									"numinlets" : 3,
									"numoutlets" : 3,
									"outlettype" : [ "", "", "" ],
									"patching_rect" : [ 20.0, 51.0, 771.0, 525.0 ],
									"style" : ""
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-1",
									"maxclass" : "newobj",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 20.0, 14.0, 30.0, 22.0 ],
									"style" : "",
									"text" : "in 1"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-2",
									"maxclass" : "newobj",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 396.0, 14.0, 75.0, 22.0 ],
									"style" : "",
									"text" : "in 2 @min 0"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-4",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 0,
									"patching_rect" : [ 20.0, 599.0, 37.0, 22.0 ],
									"style" : "",
									"text" : "out 1"
								}

							}
 ],
						"lines" : [ 							{
								"patchline" : 								{
									"destination" : [ "obj-3", 0 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-1", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-5", 0 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-1", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-3", 1 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-2", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-5", 1 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-2", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-4", 0 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-3", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-6", 0 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-3", 1 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-7", 0 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-3", 2 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-3", 2 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-9", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-5", 2 ],
									"disabled" : 0,
									"hidden" : 0,
									"source" : [ "obj-9", 0 ]
								}

							}
 ]
					}
,
					"patching_rect" : [ 15.0, 183.0, 247.0, 22.0 ],
					"style" : "",
					"text" : "gen~"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-11",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "signal" ],
					"patching_rect" : [ 32.0, 109.0, 41.0, 22.0 ],
					"style" : "",
					"text" : "click~"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-10",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 6,
					"outlettype" : [ "signal", "bang", "int", "float", "", "list" ],
					"patching_rect" : [ 15.0, 71.0, 104.0, 22.0 ],
					"style" : "",
					"text" : "typeroute~"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-9",
					"maxclass" : "newobj",
					"numinlets" : 2,
					"numoutlets" : 2,
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 515.0, 137.0, 68.0, 22.0 ],
					"style" : "",
					"text" : "route done"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-7",
					"linecount" : 4,
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 312.0, 16.5, 224.0, 62.0 ],
					"style" : "",
					"text" : "patcherargs 1. 100. @constant_time 1 @legato 0 @reattack_time 1200 @oneshot_0 @gate_output 0 @linear 1 @loop 0"
				}

			}
, 			{
				"box" : 				{
					"annotation" : "EOD",
					"comment" : "",
					"hint" : "EOD",
					"id" : "obj-6",
					"maxclass" : "outlet",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 243.0, 216.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
, 			{
				"box" : 				{
					"annotation" : "EOA",
					"comment" : "",
					"hint" : "EOA",
					"id" : "obj-5",
					"maxclass" : "outlet",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 129.0, 216.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
, 			{
				"box" : 				{
					"comment" : "",
					"id" : "obj-4",
					"maxclass" : "outlet",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 14.0, 216.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
, 			{
				"box" : 				{
					"comment" : "",
					"id" : "obj-3",
					"maxclass" : "inlet",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 243.0, 14.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
, 			{
				"box" : 				{
					"comment" : "",
					"id" : "obj-2",
					"maxclass" : "inlet",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 129.0, 14.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
, 			{
				"box" : 				{
					"comment" : "",
					"id" : "obj-1",
					"maxclass" : "inlet",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 15.0, 14.0, 30.0, 30.0 ],
					"style" : ""
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-10", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-1", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-11", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-10", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-10", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-9", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"midpoints" : [ 109.5, 104.5, 524.5, 104.5 ],
					"source" : [ "obj-10", 5 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-11", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-4", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-12", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-5", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-12", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-12", 2 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 1 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-2", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 2 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-3", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-9", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"source" : [ "obj-7", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-12", 0 ],
					"disabled" : 0,
					"hidden" : 0,
					"midpoints" : [ 573.5, 173.85321, 24.5, 173.85321 ],
					"source" : [ "obj-9", 1 ]
				}

			}
 ],
		"styles" : [ 			{
				"name" : "AudioStatus_Menu",
				"default" : 				{
					"bgfillcolor" : 					{
						"type" : "color",
						"color" : [ 0.294118, 0.313726, 0.337255, 1 ],
						"color1" : [ 0.454902, 0.462745, 0.482353, 0.0 ],
						"color2" : [ 0.290196, 0.309804, 0.301961, 1.0 ],
						"angle" : 270.0,
						"proportion" : 0.39,
						"autogradient" : 0
					}

				}
,
				"parentstyle" : "",
				"multi" : 0
			}
 ]
	}

}
