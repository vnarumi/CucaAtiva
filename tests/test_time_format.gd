@tool
extends McpTestSuite
## Testa TimeFormat (RF04/RF07) — res://scripts/core/time_format.gd.

func suite_name() -> String:
	return "time_format"


func test_zero_seconds() -> void:
	assert_eq(TimeFormat.mmss(0.0), "00:00")


func test_seconds_only() -> void:
	assert_eq(TimeFormat.mmss(45.0), "00:45")


func test_minutes_and_seconds() -> void:
	assert_eq(TimeFormat.mmss(75.0), "01:15")


func test_rounds_to_nearest_second() -> void:
	assert_eq(TimeFormat.mmss(75.6), "01:16")
	assert_eq(TimeFormat.mmss(75.4), "01:15")


func test_negative_clamps_to_zero() -> void:
	assert_eq(TimeFormat.mmss(-5.0), "00:00")


func test_large_minutes() -> void:
	assert_eq(TimeFormat.mmss(3661.0), "61:01")
