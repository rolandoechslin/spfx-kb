import { Logger, LogLevel } from "@pnp/logging";
import { HttpRequestError } from "@pnp/odata";

export class LogHelper {
  public static handleHttpError(
    objectName: string,
    methodName: string,
    error: HttpRequestError
  ): void {
    this.logError(objectName, methodName, error);
  }

  public static logError(objectName: string, methodName: string, error: Error) {
    this.exception(objectName, methodName, error);
  }

  public static verbose(
    objectName: string,
    methodName: string,
    message: string
  ) {
    message = this.formatMessage(objectName, methodName, message);
    Logger.write(message, LogLevel.Verbose);
  }

  public static info(objectName: string, methodName: string, message: string) {
    message = this.formatMessage(objectName, methodName, message);
    Logger.write(message, LogLevel.Info);
  }

  public static warning(
    objectName: string,
    methodName: string,
    message: string
  ) {
    message = this.formatMessage(objectName, methodName, message);
    Logger.write(message, LogLevel.Warning);
  }

  public static error(objectName: string, methodName: string, message: string) {
    message = this.formatMessage(objectName, methodName, message);
    Logger.write(message, LogLevel.Error);
  }

  public static exception(
    objectName: string,
    methodName: string,
    error: Error
  ) {
    error.message = this.formatMessage(objectName, methodName, error.message);
    Logger.error(error);
  }

  private static formatMessage(
    objectName: string,
    methodName: string,
    message: string
  ): string {
    let d = new Date();
    let dateStr =
      d.getDate() +
      "-" +
      (d.getMonth() + 1) +
      "-" +
      d.getFullYear() +
      " " +
      d.getHours() +
      ":" +
      d.getMinutes() +
      ":" +
      d.getSeconds() +
      "." +
      d.getMilliseconds();
    return `${dateStr} ${objectName} > ${methodName} > ${message}`;
  }
}
