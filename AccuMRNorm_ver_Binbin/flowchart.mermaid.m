---
title: Pre-Processing and Normalisation Pipeline
---
flowchart TB
    A[Info inputs]o--oInputs 
    A ---> B[BIDS conversion] --o BIDS_Conversion--> C["`Parget (parsing parameters)`"]
    --o parsed_data --> Reorientation --> Quality_Check
    
    classDef extra_boxes stroke:#D0AC31 ,stroke-width:2px;
    subgraph Inputs [Inputs]
        classDef Nodes stroke-width:1.5px;

        direction TB
        Initial_Inputs["`Raw_Dataset_Dir
        Subject_Name
        Root Code_Dir
        Template_folder`"]

    end

    subgraph BIDS_Conversion ["BIDS_Conversion (LINUX)"]
        classDef BIDS_NODE fill:#68A3AF,stroke-width:1.5px,font-size:12px;

        direction TB
        BIDS["`Using ***BRKRAW***
        (called from MATLAB using *sys*)
        `"] --Helper_Command --> BIDS_Table -- Modify based on info_sheet --> Corrected_BIDS_TABLE -- Convert_Command + Unzipping --> BIDS_Dataset["`**BIDS_Dataset (.nifti)**`"]
    end
   

    subgraph parsed_data [parsed_data]
        direction TB 
        Key_items["`Key Items Include:
        1.ANA file info (choose among ANAs)
        2.EPI files info
        3.Template file info
        ***p.s.: Info means both 
        folder&file directories 
        and filenames***`"]
    end
    class Inputs,Initial_Inputs Nodes;
    class BIDS BIDS_NODE
    class Inputs,BIDS_Conversion,parsed_data extra_boxes
    
   