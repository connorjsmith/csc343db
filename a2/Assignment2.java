import java.sql.*;

// Remember that part of your mark is for doing as much in SQL (not Java) 
// as you can. At most you can justify using an array, or the more flexible
// ArrayList. Don't go crazy with it, though. You need it rarely if at all.
import java.util.ArrayList;

public class Assignment2 {

    // A connection to the database
    Connection connection;

    Assignment2() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to the database and sets the search path.
     * 
     * Establishes a connection to be used for this session, assigning it to the
     * instance variable 'connection'. In addition, sets the search path to
     * markus.
     * 
     * @param url
     *            the url for the database
     * @param username
     *            the username to be used to connect to the database
     * @param password
     *            the password to be used to connect to the database
     * @return true if connecting is successful, false otherwise
     */
    public boolean connectDB(String URL, String username, String password) {
        try {
            connection = DriverManager.getConnection(URL, username, password);
            Statement searchpathStatement = connection.createStatement();
            searchpathStatement.execute("SET search_path TO markus");
        } catch (SQLException se) {
            System.err.println("SQL Exception.<Message>: " + se.getMessage()); // TODO: remove?
            return false;
        }
        return true;
    }

    /**
     * Closes the database connection.
     * 
     * @return true if the closing was successful, false otherwise
     */
    public boolean disconnectDB() {
        // TODO: replace this return statement with an implementation of this method!
        try {
            connection.close();
        } catch (SQLException se) {
            System.err.println("SQL Exception.<Message>: " + se.getMessage()); // TODO remove?
            return false;
        }
        return true;
    }

    /**
     * Assigns a grader for a group for an assignment.
     * 
     * Returns false if the groupID does not exist in the AssignmentGroup table,
     * if some grader has already been assigned to the group, or if grader is
     * not either a TA or instructor.
     * 
     * @param groupID
     *            id of the group
     * @param grader
     *            username of the grader
     * @return true if the operation was successful, false otherwise
     */
    public boolean assignGrader(int groupID, String grader) {
        // TODO: replace this return statement with an implementation of this method!
        PreparedStatement ps;
        ResultSet rs;
        try {
            // Check if there is a grader associated with this group
            String graderAlreadyExists = "SELECT username FROM Grader WHERE group_id = ?";
            ps = connection.prepareStatement(graderAlreadyExists);
            ps.setInt(1, groupID);
            rs = ps.executeQuery();
            if (rs.next()) {
                // Since the Grader.username column references a primary key, it cannot be NULL
                // Therefore this groupID already has a grader
                System.out.println("Group '" + groupID + "' already has a grader"); // TODO remove?
                return false;
            }

            // Check that the new grader is a TA or Prof
            String graderIsNotTAOrProf = "SELECT username FROM MarkusUser WHERE username = ? AND (type = 'TA' OR type = 'instructor')";
            ps = connection.prepareStatement(graderIsNotTAOrProf);
            ps.setString(1, grader);
            rs = ps.executeQuery();
            if (!rs.next()) {
                System.out.println("The grader '" + grader + "' is not a Prof or TA"); // TODO remove?
                return false; // The grader is not a TA or Prof, or is not a Markus User
            }

            // Check the group exists in the AssignmentGroup table
            String groupIDExists = "SELECT group_id FROM AssignmentGroup WHERE group_id = ?";
            ps = connection.prepareStatement(groupIDExists);
            ps.setInt(1, groupID);
            rs = ps.executeQuery();
            if (!rs.next()) {
                System.out.println("Group '" + groupID + "' does not exist"); // TODO remove?
                return false; // The group does not exist
            }

            // Insert the new valid record
            String insert = "INSERT INTO Grader(username, group_id) VALUES (?, ?)";
            ps = connection.prepareStatement(insert);
            ps.setString(1, grader);
            ps.setInt(2, groupID);
            System.out.println("Executing <" + insert + "> with params (" + groupID + ", " + grader + ")");
            // rs = ps.executeQuery();
        } catch (SQLException se) {
            // We got an error, return false
            System.err.println("SQL Exception.<Message>: " + se.getMessage());
            return false;
        }
        return true;
    }

    /**
     * Adds a member to a group for an assignment.
     * 
     * Records the fact that a new member is part of a group for an assignment.
     * Does nothing (but returns true) if the member is already declared to be
     * in the group.
     * 
     * Does nothing and returns false if any of these conditions hold: - the
     * group is already at capacity, - newMember is not a valid username or is
     * not a student, - there is no assignment with this assignment ID, or - the
     * group ID has not been declared for the assignment.
     * 
     * @param assignmentID
     *            id of the assignment
     * @param groupID
     *            id of the group to receive a new member
     * @param newMember
     *            username of the new member to be added to the group
     * @return true if the operation was successful, false otherwise
     */
    public boolean recordMember(int assignmentID, int groupID, String newMember) {
        // TODO: replace this return statement with an implementation of this method!
        String studentAlreadyInGroup = "TODO";

        String groupAtCapacity = "TODO";

        String newMemberNotValidStudent = "TODO";

        String assignmentDoesNotExist = "TODO";

        String groupIDNotDeclaredForAssignment = "TODO";
        return false;
    }

    /**
     * Creates student groups for an assignment.
     * 
     * Finds all students who are defined in the Users table and puts each of
     * them into a group for the assignment. Suppose there are n. Each group
     * will be of the maximum size allowed for the assignment (call that k),
     * except for possibly one group of smaller size if n is not divisible by k.
     * Note that k may be as low as 1.
     * 
     * The choice of which students to put together is based on their grades on
     * another assignment, as recorded in table Results. Starting from the
     * highest grade on that other assignment, the top k students go into one
     * group, then the next k students go into the next, and so on. The last n %
     * k students form a smaller group.
     * 
     * In the extreme case that there are no students, does nothing and returns
     * true.
     * 
     * Students with no grade recorded for the other assignment come at the
     * bottom of the list, after students who received zero. When there is a tie
     * for grade (or non-grade) on the other assignment, takes students in order
     * by username, using alphabetical order from A to Z.
     * 
     * When a group is created, its group ID is generated automatically because
     * the group_id attribute of table AssignmentGroup is of type SERIAL. The
     * value of attribute repo is repoPrefix + "/group_" + group_id
     * 
     * Does nothing and returns false if there is no assignment with ID
     * assignmentToGroup or no assignment with ID otherAssignment, or if any
     * group has already been defined for this assignment.
     * 
     * @param assignmentToGroup
     *            the assignment ID of the assignment for which groups are to be
     *            created
     * @param otherAssignment
     *            the assignment ID of the other assignment on which the
     *            grouping is to be based
     * @param repoPrefix
     *            the prefix of the URL for the group's repository
     * @return true if successful and false otherwise
     */

    private int getLargestGroupId() throws SQLException, SQLTimeoutException {
        String largestGroupIdStatement = "SELECT MAX(group_id) FROM AssignmentGroup";
        int largestGroupId = 0;
        PreparedStatement ps = connection.prepareStatement(largestGroupIdStatement);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            largestGroupId = rs.getInt(1); // no existing groups (null) will return 0
        }  
        return largestGroupId;
    }

    private void setNextAssignmentGroupSerialValue(int newValue) throws SQLException, SQLTimeoutException {
        String setSerial = "SELECT setval('assignmentgroup_group_id_seq', ?, false)"; // false so we user newValue for our next insert
        PreparedStatement ps = connection.prepareStatement(setSerial);
        ps.setInt(1, newValue);
        ps.executeQuery();
    }

    private int autocreateSingleGroup(int assignmentID, String repoPrefix) throws SQLException, SQLTimeoutException {
        // Set the serial value to be populated by the next insert
        int thisGroupId = getLargestGroupId() + 1;
        setNextAssignmentGroupSerialValue(thisGroupId);

        String repo_url = repoPrefix + "/group_" + thisGroupId;
        String insertGroup = "INSERT INTO AssignmentGroup(assignment_id, repo) VALUES(?, ?)"; // returns a uniquely generated group_id
        PreparedStatement ps = connection.prepareStatement(insertGroup);
        ps.setInt(1, assignmentID);
        ps.setString(2, repo_url);
        ps.executeUpdate();
        return thisGroupId;
    }

    private boolean addStudentsToGroup(int groupID, ArrayList<String> studentUsernames) {
        String insertStudent = "INSERT INTO Membership VALUES (?, ?)";
        for (String username : studentUsernames) {


        }
        return false;
    }
        
        
    public boolean createGroups(int assignmentToGroup, int otherAssignment,
            String repoPrefix) {
        // TODO: replace this return statement with an implementation of this method!
        String noAssignmentToGroupFound = "TODO";
        String noOtherAssignmentFound = "TODO";
        String otherAssignmentStudentsSorted = "TODO";
        String maxGroupSizeQuery = "TODO";
        int maxGroupSizeForAssignment = 0; // TODO: get this value from

        // TODO: get student_iterator as a sorted relation as specified in the docstring
        /*
        while (student_iterator.next()) {
            int groupID = autocreateSingleGroup(assignmentToGroup, repoPrefix);

            // get up to maxGroupSizeForAssignment students
            ArrayList<String> studentUsernames = new ArrayList();
            studentUseranmes.append(student_iterator.getString("username"));
            int current_count = 1;
            while (current_count < maxGroupSizeForAssignment && student_iterator.next()) {
                current_count++;
                studentUseranmes.append(student_iterator.getString("username"));
            }
            boolean success = addStudentsToGroup(groupID, studentUsernames);
            if (!success) return false;
        }
        */

        
        return false;
    }

    public static boolean testAssignGrader() {
        System.out.println("\n\nStarting test 'testAssignGrader'\n");
        Assignment2 a2;
        boolean result; // TODO remove this
        try {
            a2 = new Assignment2();
        } catch (SQLException e) {
            System.out.println("Got constructor exception " + e);
            System.out.println("FAILED!");return false;
        }
        System.out.println("Connecting to DB");
        result = a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-smithc63", "smithc63", "");
        if (result != true) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Adding a new grader for a group");
        result = a2.assignGrader(2002, "i1");
        if (result != true) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Failing to add a new grader because they are not a TA or Prof");
        result = a2.assignGrader(2002, "s1");
        if (result != false) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Failing to add a new grader because they are not in the MarkusUser table");
        result = a2.assignGrader(2001, "not_a_user");
        if (result != false) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Failing to add a new grader because the group does not exist");
        result = a2.assignGrader(2001000, "i1");
        if (result != false) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Failing when the group already has a grader");
        result = a2.assignGrader(2000, "i1");
        if (result != false) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("TEST CASE: Failing gracefully when username is NULL");
        result = a2.assignGrader(2001000, null);
        if (result != false) {
            System.out.println("FAILED!");
            return false;
        }

        System.out.println("Disconnecting from DB");
        result = a2.disconnectDB();
        if (result != true) {
            System.out.println("FAILED!");
            return false;
        }
        System.out.println("\nPassed test 'testAssignGrader'");
        return true; // all tests passed
    }

    public static boolean testRecordMember() {
        System.out.println("\n\nStarting test 'testRecordMember'\n");
        return false;
    }

    public static boolean testCreateGroups() {
        System.out.println("\n\nStarting test 'testCreateGroups'\n");
        Assignment2 a2;
        boolean result;
        try {
            a2 = new Assignment2();
        } catch (SQLException e) {
            System.out.println("Got constructor exception " + e);
            System.out.println("FAILED!");return false;
        }
        System.out.println("Connecting to DB");
        result = a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-smithc63", "smithc63", "");
        if (result != true) {
            System.out.println("FAILED!");
            return false;
        }

        try {
            System.out.println("TEST CASE: auotCreateSignleGroup correctly generates serial fields");
            int first = a2.autocreateSingleGroup(1000,"test_repo_prefix");
            int second = a2.autocreateSingleGroup(1000,"test_repo_prefix");
            int third = a2.autocreateSingleGroup(1001,"test_repo_prefix");
            if (first != second - 1 || first != third - 2) {
                System.out.println("FAILED!");
                return false;
            }
            // TODO test other helper functions here
        } catch (SQLException e) {
            System.out.println("FAILED! Got exception: " + e.getMessage());
            return false;
        }

        System.out.println("Disconnecting from DB");
        result = a2.disconnectDB();
        if (result != true) {
            System.out.println("FAILED!");
            return false;
        }
        System.out.println("\nPassed test 'testCreateGroups");
        return true;
    }

    public static void main(String[] args) {
        // TODO: You can put testing code in here. It will not affect our autotester.

        if(!testAssignGrader()){
            System.out.println("\n\ntestAssignGrader failed one or more tests!");
            return;
        }
        if(!testCreateGroups()){
            System.out.println("\n\ntestCreateGroups failed one or more tests!");
            return;
        }
        if(!testRecordMember()){
            System.out.println("\n\ntestRecordMember failed one or more tests!");
            return;
        }
    }
}
