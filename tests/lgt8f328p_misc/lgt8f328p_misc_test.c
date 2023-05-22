#include "unity.h"
#include "lgt8f328p_misc.h"


//##############################
//Globals
//##############################


//##############################
//Tests
//##############################


// This test will fail. Delete it once you confirm so.
void failing_test(void)
{
    TEST_FAIL();
    TEST_FAIL_MESSAGE("Unit Testing Working! Now delete this test!");
}


//##############################
//Unity Specific Functions
//##############################

//Runs before each test.
void setUp(void)
{
}

//Runs after each test.
void tearDown(void)
{
}

// not needed when using generate_test_runner.rb
int main(void) {
    UNITY_BEGIN();
    RUN_TEST(failing_test);
    return UNITY_END();
}
