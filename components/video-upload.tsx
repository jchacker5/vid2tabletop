"use client";

import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { toast } from "@/components/ui/use-toast";
import { Upload, X } from "lucide-react";
import * as React from "react";
import { useCallback, useState } from "react";
import { useDropzone } from "react-dropzone";

export function VideoUpload() {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const videoFile = acceptedFiles[0];
    if (videoFile) {
      if (videoFile.type.startsWith("video/")) {
        setFile(videoFile);
      } else {
        toast({
          title: "Invalid file type",
          description: "Please upload a video file.",
          variant: "destructive",
        });
      }
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      "video/*": [".mp4", ".mov", ".avi"],
    },
    maxFiles: 1,
  });

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    setProgress(0);

    // Simulate upload progress
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 95) {
          clearInterval(interval);
          return prev;
        }
        return prev + 5;
      });
    }, 500);

    try {
      // TODO: Implement actual upload logic here
      await new Promise((resolve) => setTimeout(resolve, 5000));
      setProgress(100);
      toast({
        title: "Upload complete",
        description: "Your video has been uploaded successfully.",
      });
    } catch (error) {
      toast({
        title: "Upload failed",
        description: "There was an error uploading your video.",
        variant: "destructive",
      });
    } finally {
      setUploading(false);
      clearInterval(interval);
    }
  };

  const handleRemove = () => {
    setFile(null);
    setProgress(0);
  };

  return (
    <div className="space-y-4">
      <div
        {...getRootProps()}
        className={`border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors
          ${
            isDragActive
              ? "border-primary bg-primary/5"
              : "border-muted-foreground/25"
          }
          ${file ? "bg-muted/50" : ""}`}
      >
        <input {...getInputProps()} />
        {file ? (
          <div className="space-y-2">
            <p className="text-sm font-medium">{file.name}</p>
            <p className="text-xs text-muted-foreground">
              {(file.size / (1024 * 1024)).toFixed(2)} MB
            </p>
          </div>
        ) : (
          <div className="space-y-2">
            <Upload className="mx-auto h-8 w-8 text-muted-foreground" />
            <p className="text-sm font-medium">
              {isDragActive ? "Drop the video here" : "Drag & drop video here"}
            </p>
            <p className="text-xs text-muted-foreground">
              Or click to select a file
            </p>
          </div>
        )}
      </div>

      {file && (
        <div className="space-y-2">
          {uploading && <Progress value={progress} className="h-2" />}
          <div className="flex justify-between gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={handleRemove}
              disabled={uploading}
            >
              <X className="mr-2 h-4 w-4" />
              Remove
            </Button>
            <Button size="sm" onClick={handleUpload} disabled={uploading}>
              {uploading ? "Uploading..." : "Upload"}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
