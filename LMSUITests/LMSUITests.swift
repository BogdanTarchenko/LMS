import XCTest

final class LMSUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
}

// MARK: - Auth Flow

final class AuthUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_loginScreen_elementsVisible() {
        XCTAssertTrue(app.textFields["email_field"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.secureTextFields["password_field"].exists)
        XCTAssertTrue(app.buttons["login_button"].exists)
    }

    func test_login_emptyFields_showsValidationErrors() {
        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["email_error"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["password_error"].exists)
    }

    func test_login_invalidEmail_showsEmailError() {
        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("notanemail")

        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("password123")

        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["email_error"].waitForExistence(timeout: 2))
    }

    func test_login_shortPassword_showsPasswordError() {
        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("test@test.com")

        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("123")

        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["password_error"].waitForExistence(timeout: 2))
    }

    func test_login_validCredentials_navigatesToClassList() {
        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("abobus123@mail.ru")

        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("12345678")

        app.buttons["login_button"].tap()

        // Проверяем факт навигации: экран логина исчезает, появляется таббар
        let loginButton = app.buttons["login_button"]
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))
        XCTAssertFalse(loginButton.exists)
    }

    func test_login_navigatesToRegister() {
        let registerButton = app.buttons["Зарегистрироваться"]
        XCTAssertTrue(registerButton.waitForExistence(timeout: 3))
        registerButton.tap()

        XCTAssertTrue(app.textFields["first_name_field"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.textFields["last_name_field"].exists)
        XCTAssertTrue(app.buttons["register_button"].exists)
    }

    func test_register_emptyFields_showsValidationErrors() {
        app.buttons["Зарегистрироваться"].tap()
        app.buttons["register_button"].tap()

        XCTAssertTrue(app.staticTexts["email_error"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["password_error"].exists)
    }

    func test_register_passwordMismatch_showsConfirmError() {
        app.buttons["Зарегистрироваться"].tap()

        app.textFields["first_name_field"].tap()
        app.textFields["first_name_field"].typeText("Иван")

        app.textFields["last_name_field"].tap()
        app.textFields["last_name_field"].typeText("Петров")

        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("ivan@test.com")

        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("12345678")

        app.secureTextFields["confirm_password_field"].tap()
        app.secureTextFields["confirm_password_field"].typeText("1234567899")

        app.buttons["register_button"].tap()

        XCTAssertTrue(app.staticTexts["confirm_password_error"].waitForExistence(timeout: 2))
    }

    func test_register_validData_navigatesToClassList() {
        app.buttons["Зарегистрироваться"].tap()

        app.textFields["first_name_field"].tap()
        app.textFields["first_name_field"].typeText("Иван")

        app.textFields["last_name_field"].tap()
        app.textFields["last_name_field"].typeText("Петров")

        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("ivan@test.com")

        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("12345678")

        app.secureTextFields["confirm_password_field"].tap()
        app.secureTextFields["confirm_password_field"].typeText("12345678")

        app.buttons["register_button"].tap()

        // Проверяем факт навигации: появляется таббар
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }
}

// MARK: - Class List Flow

final class ClassListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_AUTHENTICATED"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_classListScreen_elementsVisible() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["add_class_button"].exists)
    }

    func test_classListScreen_showsClasses() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Математика 101"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Физика"].exists)
        XCTAssertTrue(app.staticTexts["История"].exists)
    }

    func test_addClassButton_showsActionSheet() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.buttons["add_class_button"].tap()

        XCTAssertTrue(app.buttons["Создать класс"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Присоединиться по коду"].exists)
    }

    func test_createClass_showsSheet() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.buttons["add_class_button"].tap()
        app.buttons["Создать класс"].tap()

        XCTAssertTrue(app.textFields["class_name_field"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["create_class_button"].exists)
    }

    func test_createClass_emptyName_disablesButton() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.buttons["add_class_button"].tap()
        app.buttons["Создать класс"].tap()

        let createButton = app.buttons["create_class_button"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 3))
        XCTAssertFalse(createButton.isEnabled)
    }

    func test_createClass_withName_createsAndDismisses() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.buttons["add_class_button"].tap()
        app.buttons["Создать класс"].tap()

        let nameField = app.textFields["class_name_field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText("Новый класс")

        app.buttons["create_class_button"].tap()

        // После создания шит закрывается — поле ввода исчезает
        let fieldGone = NSPredicate(format: "exists == false")
        expectation(for: fieldGone, evaluatedWith: nameField)
        waitForExpectations(timeout: 5)
    }

    func test_joinClass_showsSheet() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.buttons["add_class_button"].tap()
        app.buttons["Присоединиться по коду"].tap()

        XCTAssertTrue(app.textFields["join_code_field"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["join_class_button"].exists)
    }

    func test_tapClass_navigatesToDetail() {
        XCTAssertTrue(app.staticTexts["Математика 101"].waitForExistence(timeout: 5))
        app.staticTexts["Математика 101"].tap()

        XCTAssertTrue(app.navigationBars["Математика 101"].waitForExistence(timeout: 3))
    }

    func test_tabBar_profileTabNavigatesToProfile() {
        XCTAssertTrue(app.navigationBars["Мои классы"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Профиль"].tap()

        XCTAssertTrue(app.navigationBars["Профиль"].waitForExistence(timeout: 3))
    }
}

// MARK: - Class Detail Flow

final class ClassDetailUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_AUTHENTICATED"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func openClassDetail() {
        XCTAssertTrue(app.staticTexts["Математика 101"].waitForExistence(timeout: 5))
        app.staticTexts["Математика 101"].tap()
        XCTAssertTrue(app.navigationBars["Математика 101"].waitForExistence(timeout: 3))
    }

    func test_classDetail_showsAssignments() {
        openClassDetail()

        XCTAssertTrue(app.staticTexts["Домашнее задание 1"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Контрольная работа"].exists)
    }

    func test_classDetail_ownerSeesCreateButton() {
        openClassDetail()

        XCTAssertTrue(app.buttons["create_assignment_button"].waitForExistence(timeout: 3))
    }

    func test_classDetail_createAssignment_showsSheet() {
        openClassDetail()

        app.buttons["create_assignment_button"].tap()

        XCTAssertTrue(app.textFields["assignment_title_field"].waitForExistence(timeout: 3))
    }

    func test_classDetail_membersButton_navigatesToMembers() {
        openClassDetail()

        app.navigationBars.buttons.matching(identifier: "person.2").firstMatch.tap()

        XCTAssertTrue(app.navigationBars["Участники"].waitForExistence(timeout: 3))
    }

    func test_classDetail_tapAssignment_navigatesToDetail() {
        openClassDetail()

        XCTAssertTrue(app.staticTexts["Домашнее задание 1"].waitForExistence(timeout: 3))
        app.staticTexts["Домашнее задание 1"].tap()

        XCTAssertTrue(app.navigationBars["Домашнее задание 1"].waitForExistence(timeout: 3))
    }
}

// MARK: - Profile Flow

final class ProfileUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_AUTHENTICATED"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func openProfile() {
        XCTAssertTrue(app.tabBars.buttons["Профиль"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Профиль"].tap()
        XCTAssertTrue(app.navigationBars["Профиль"].waitForExistence(timeout: 3))
    }

    func test_profileScreen_showsUserInfo() {
        openProfile()

        XCTAssertTrue(app.staticTexts["Иван"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["ivan@test.com"].exists)
    }

    func test_profileScreen_logoutButtonExists() {
        openProfile()

        XCTAssertTrue(app.buttons["logout_button"].waitForExistence(timeout: 3))
    }

    func test_profileScreen_logout_returnsToLogin() {
        openProfile()

        app.buttons["logout_button"].tap()

        XCTAssertTrue(app.buttons["Выйти"].waitForExistence(timeout: 2))
        app.buttons["Выйти"].tap()

        XCTAssertTrue(app.buttons["login_button"].waitForExistence(timeout: 5))
    }
}
