extends Node

enum  TEST_TYPE {
	SOLO1,
	SOLO2,
	SOLO3,
}

signal initializing_test(test_type: TEST_TYPE);
signal retry_test;

func initialize_test(test_type: TEST_TYPE):
	initializing_test.emit(test_type)
