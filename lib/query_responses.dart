class QueryResponses {
  static String getResponse(String query) {
    // Normalize query to lower case and trim whitespace for better matching
    query = query.toLowerCase().trim();

    // Basic keyword matching to handle variations in user queries
    if (query.contains("what is") &&
        query.contains("unit name") &&
        query.contains("about")) {
      return "This unit covers the Applied project 2 where you will be working on university project.";
    } else if (query.contains("list") &&
        query.contains("all") &&
        query.contains("study units")) {
      return "Here is a list of all your study units: NIT3171, NEF3002, NIT2171, NIT2232";
    } else if (query.contains("show me details of") &&
        query.contains("NEF3002")) {
      return "The details for NEF3002 are as follows: Assessment 1 - Progress Report (10%) - due by Week 1 Wednesday 23:59pm, Assessment 2 - Final system delivery and report (70%) - due by Week 4 Monday 23:59pm.";
    } else if (query.contains("objectives of") && query.contains("NEF3002")) {
      return "The objectives of NEF3002 is to help students to enhance their knowledge and build confidence.";
    } else if (query.contains("who is the instructor for") &&
        query.contains("NEF3002")) {
      return "The instructor for NEF3002 is Dr.Sardar Farhad.";
    } else if (query.contains("assignments") &&
        query.contains("due this week")) {
      return "You have the following assignments due this week:  Final system delivery and report (70%) - due by Week 4 Monday 23:59pm.";
    } else if (query.contains("when is the deadline for") &&
        query.contains("NEF3002")) {
      return "The deadline for NEF3002 is 15/11/2024 at 11:59PM.";
    } else if (query.contains("assignments coming up in") &&
        query.contains("November")) {
      return "Here are your assignments due in November: 1.Project Diary (due at 1st NOvember), Final report submission (due at 15th November).";
    } else if (query.contains("show all my assignments for") &&
        query.contains("unit name")) {
      return "All assignments for [Unit Name] are: [Assignment List].";
    } else if (query.contains("assignments due tomorrow")) {
      return "Yes, you have Final report submission due tomorrow.";
    } else if (query.contains("remind me about") &&
        query.contains("assignment") &&
        query.contains("deadline")) {
      return "I've set a reminder for NEF3002 due on 15/11/2024.";
    } else if (query.contains("what should i focus on this week")) {
      return "This week, focus on [Topics/Assignments].";
    } else if (query.contains("set up a study plan for") &&
        query.contains("unit name")) {
      return "Your study plan for [Unit Name] includes: [Study Plan Details].";
    } else if (query.contains("upcoming study sessions")) {
      return "Your upcoming study sessions are scheduled as follows: [Sessions].";
    } else if (query.contains("show me my timetable for") &&
        query.contains("unit code")) {
      return "Here is the timetable for [Unit Code]: [Timetable Details].";
    } else if (query.contains("how can i contact my supervisor")) {
      return "You can contact your supervisor via sardar@edu.vu.au.";
    } else if (query.contains("can i schedule a meeting with my supervisor")) {
      return "You can schedule a meeting through the calendar feature.";
    } else if (query.contains("peer tutor available for") &&
        query.contains("unit name")) {
      return "Yes, there is a peer tutor available for [Unit Name].";
    } else if (query.contains("help me contact my study buddy for") &&
        query.contains("NEF3002")) {
      return "You can contact your study buddy through VU collaborate.";
    } else if (query.contains("what can you help me with")) {
      return "I can help you with queries related to your study units, assignments, and schedule.";
    } else if (query
        .contains("who are my group mates for the project NEF3002")) {
      return "My group mates are: 1.Sudeep Parajuli, 2.Sushmita wagle, 3.Priyanka subedi, 4.Pratik shrestha.";
    } else if (query.contains("how can i add a new study unit")) {
      return "Go to 'Manage Units' and click on 'Add New Unit'.";
    } else if (query.contains("show me how to use the calendar")) {
      return "The calendar helps you keep track of deadlines and meetings.";
    } else if (query.contains("how do i log out")) {
      return "You can log out by tapping the profile icon and selecting 'Log Out'.";
    }

    // Default response if no matches found
    return "I'm sorry, I don't understand that question.";
  }
}
