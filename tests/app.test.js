import { describe, expect, it } from "vitest";
import { TestDriver } from "testdriverai/vitest/hooks";

describe("RoomMates Application", () => {
  it("should explore the homepage, login, and registration flow", async (context) => {
    const testdriver = TestDriver(context);

    const appUrl =
      process.env.APP_URL ||
      "https://sellers-theoretical-vancouver-physical.trycloudflare.com";

    await testdriver.provision.chrome({ url: appUrl });

    // Verify homepage
    const homeAssert = await testdriver.assert(
      "the RoomMates logo and Why RoomMates heading are visible"
    );
    expect(homeAssert).toBeTruthy();

    // Navigate to registration section via header navigation
    await testdriver.find("Registration link in the header navigation").click();

    // Wait for smooth scroll animation to settle
    await testdriver.find("Log In button", { timeout: 15000 });

    const regSectionAssert = await testdriver.assert(
      "the Log In and Sign Up buttons are visible in the registration section"
    );
    expect(regSectionAssert).toBeTruthy();

    // Navigate to Log In page
    await testdriver.find("Log In button").click();

    // Wait for the login page to load
    await testdriver.find("Email input field", { timeout: 15000 });

    const loginAssert = await testdriver.assert(
      "the login form with email and password inputs is visible"
    );
    expect(loginAssert).toBeTruthy();

    // Enter login credentials
    await testdriver.find("Email input field").click();
    await testdriver.type("test@example.com");

    await testdriver.find("Password input field").click();
    await testdriver.type("Password123");

    // Navigate to Sign Up flow
    await testdriver.find("Sign up link").click();

    // Wait for Step 1 registration page to load
    await testdriver.find("Name input field", { timeout: 15000 });

    const step1Assert = await testdriver.assert(
      "the Create an Account - Step 1 form is visible with Name, Email, Mobile, and Password fields"
    );
    expect(step1Assert).toBeTruthy();

    // Fill Step 1 of registration
    await testdriver.find("Name input field").click();
    await testdriver.type("Alex Smith");

    await testdriver.find("Email input field").click();
    await testdriver.type("alex@example.com");

    await testdriver.find("Mobile input field").click();
    await testdriver.type("5551234567");

    await testdriver.find("Password input field").click();
    await testdriver.type("Password123");

    await testdriver.find("Next button").click();

    // Wait for Step 2 page to load
    await testdriver.find("Nationality input field", { timeout: 15000 });

    // Verify navigation to Step 2
    const step2Assert = await testdriver.assert(
      "the Create an Account - Step 2 form is displayed with Nationality, Gender, and Bio fields"
    );
    expect(step2Assert).toBeTruthy();
  });
});
