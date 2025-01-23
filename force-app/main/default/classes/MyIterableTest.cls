@IsTest
public class MyIterableTest {
    @IsTest
    static void testIterableForLoop() {
        // Step 1: Create a list of strings
        List<String> strings = new List<String>{'Hello', 'World'};

        // Step 2: Create an instance of MyIterable with the list of strings
        MyIterable myIterable = new MyIterable(strings);

        // Step 3: Use a for loop to iterate over the MyIterable instance
        for (String str : myIterable) {
            // Step 4: Print each string using System.debug
            System.debug(str);
        }

        // Assertion to validate the test
        // Collecting the output into a list
        List<String> expectedOutput = new List<String>{'Hello', 'World'};
        List<String> actualOutput = new List<String>();

        for (String str : myIterable) {
            actualOutput.add(str);
        }

        // Assert that both lists match
        System.assertEquals(expectedOutput, actualOutput, 'The MyIterable iteration did not produce the expected output.');
    }
}