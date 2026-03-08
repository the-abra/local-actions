# Contributing

Thank you for your interest in improving Local Actions Runner!

## How to Contribute

1.  **Fork the repository.**
2.  **Create a new branch** for your feature or bug fix.
3.  **Implement your changes.**
4.  **Test your changes** by running the `run-local.sh` script with various workflow files.
5.  **Submit a Pull Request** with a clear description of your changes.

## Development Requirements

-   Docker
-   `yq` (YAML processor)

## Coding Standards

-   Use clear, descriptive variable names in the bash script.
-   Ensure compatibility with standard POSIX shells where possible.
-   Maintain the privacy-focused design (automatically skipping steps with secrets).
