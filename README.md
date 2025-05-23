# Txt-List-Merger
# List Merger

This PowerShell script, `Txt List Merger.ps1`, is a versatile tool designed to merge the contents of multiple text-based lists into a single output file. While it excels at combining simple text lists, it's particularly useful for merging lists of specific data types, such as link domain lists, or any data where each item is on a new line.

## Features

* **Merges Multiple Text-Based Lists:** Combines the content of several text files, treating each line as a distinct item in a list.
* **Ideal for Various List Types:**
    * **Text Lists:** Standard lists of words, phrases, or sentences.
    * **Link Domain Lists:** Merges lists of website domains.
    * **Configuration Lists:** Combines configuration settings where each setting is on a new line.
    * **Data Lists:** Any data where each item is separated by a newline.
* **Flexible Input:** Accepts input files through:
    * Individual file paths.
    * Wildcard patterns to select multiple files in a directory.
* **Customizable Output:**
    * Specify the name and path of the output file.
    * Option to append content to an existing output file or overwrite it.
* **Order Preservation:** Maintains the order of lines (list items) within each input file in the output.
* **Error Handling:** Includes error handling for file access issues.
* **User Interface:** Provides a simple graphical user interface (GUI) for ease of use.
* **Optimized Performance:** Uses PowerShell jobs for faster merging of large files.

## How It Works

The script operates with a GUI and utilizes background jobs to efficiently merge files. Here's a breakdown:

1.  **GUI Initialization:**
    * Creates a form with elements for file selection, output path, and actions.
    * Includes:
        * List box to display selected input files.
        * Buttons to add and remove files from the selection.
        * Text box to specify the output file path.
        * A "Merge" button to start the merging process.
        * A label to display status messages.

2.  **File Selection:**
    * The "Add Files" button opens a file dialog, allowing the user to select multiple text files.
    * The selected files are displayed in the list box.
    * The "Remove Selected" button removes highlighted files from the list.

3.  **Output Path Specification:**
    * The user enters the desired path and filename for the merged output in the text box.

4.  **Merge Action:**
    * When the "Merge" button is clicked, the script validates the input:
        * Ensures at least one input file is selected.
        * Checks if an output file path is provided.
        * Prompts the user if the output file already exists, asking whether to overwrite.
    * The `Merge-FilesOptimized` function is called to handle the actual merging.

5.  **Optimized Merging with Jobs (`Merge-FilesOptimized`):**
    * This function splits the input files into chunks to be processed concurrently.
    * For each chunk, a PowerShell job is started to read the file content.
    * The main process waits for all jobs to complete.
    * The content from each job is appended to the output file.
    * This parallel processing significantly speeds up the merging process, especially for large files.
    * Includes error handling within the jobs to manage file access issues.

6.  **Status Updates:**
    * The GUI's status label is updated throughout the process to inform the user about:
        * The start and end of the merge.
        * Any errors encountered.
        * Completion messages.

7.  **Completion Message:**
    * A message box is displayed upon successful completion, indicating that the files have been merged.

## Usage

1.  **Run the Script:** Execute the `Txt List Merger.ps1` PowerShell script.
2.  **Add Files:** Click the "Add Files" button and select the text files you want to merge.
3.  **Specify Output:** Enter the desired path and filename for the merged output in the text box.
4.  **Merge:** Click the "Merge" button.
5.  **Wait for Completion:** The script will display status messages during the process.
6.  **View Output:** Once the merge is complete, the merged file will be saved at the specified location.

## Examples

These examples illustrate how the script can be used (though the GUI makes it interactive, these show the underlying concepts):

* **Merging text files:**
    * Select `file1.txt` and `file2.txt` using the "Add Files" button.
    * Enter `merged.txt` in the output text box.
    * Click "Merge".

* **Merging domain lists:**
    * Select `domains_list_a.txt` and `domains_list_b.txt`.
    * Enter `combined_domains.txt`.
    * Click "Merge".

* **Merging configuration settings:**
    * Select `config_part1.txt` and `config_part2.txt`.
    * Enter `final_config.txt`.
    * Click "Merge".

## Potential Enhancements

* **Encoding Options:** Add support for specifying input and output file encodings.
* **Delimiter Options:** Allow the user to specify a custom delimiter to insert between the content of merged files.
* **Duplicate Removal:** Implement an option to automatically remove duplicate lines during the merge.
* **Sorting:** Add functionality to sort the merged list items.
* **Advanced Filtering:** Implement options to filter lines based on patterns or criteria before merging.
* **Recursive Directory Input:** Enable the selection of files from subdirectories.

## Contributing

Contributions are welcome! To contribute:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Implement your changes.
4.  Test thoroughly.
5.  Submit a pull request.
