(require 'shr)
(require 'browse-url)

(setq browse-url-browser-function 'eww-browse-url)

(defun shr-put-image2 (spec alt &optional flags)
  "Insert image SPEC with a string ALT.  Return image.
SPEC is either an image data blob, or a list where the first
element is the data blob and the second element is the content-type."
  (if (display-graphic-p)
      (let* ((size (cdr (assq 'size flags)))
	     (data (if (consp spec)
		       (car spec)
		     spec))
	     (content-type (and (consp spec)
				(cadr spec)))
	     (start (point))
	     (image (cond
		     ((eq size 'original)
		      (create-image data nil t :ascent 100
				    :format content-type))
		     ((eq content-type 'image/svg+xml)
                      (when (image-type-available-p 'svg)
		        (create-image data 'svg t :ascent 100)))
		     ((eq size 'full)
		      (ignore-errors
			(shr-rescale-image data content-type
                                           (plist-get flags :width)
                                           (plist-get flags :height))))
		     (t
		      (ignore-errors
			(shr-rescale-image data content-type
                                           (plist-get flags :width)
                                           (plist-get flags :height)))))))
        (when image
	  ;; When inserting big-ish pictures, put them at the
	  ;; beginning of the line.
;;;	  (when (and (> (current-column) 0)
;;;		     (> (car (image-size image t)) 400))
;;;	    (insert "\n"))
	  (if (eq size 'original)
	      (insert-sliced-image image (or alt "*") nil 20 1)
	    (insert-image image (or alt "*")))
	  (put-text-property start (point) 'image-size size)
	  (when (and shr-image-animate
                     (cdr (image-multi-frame-p image)))
            (image-animate image nil 60)))
	image)
    (insert (or alt ""))))

(fmakunbound 'shr-tag-image)
(defun shr-tag-img (dom &optional url)
  (when (or url
	    (and dom
		 (or (> (length (dom-attr dom 'src)) 0)
                     (> (length (dom-attr dom 'srcset)) 0))))
;    (when (> (current-column) 0)
;      (insert "\n"))
    (let ((alt (dom-attr dom 'alt))
          (width (shr-string-number (dom-attr dom 'width)))
          (height (shr-string-number (dom-attr dom 'height)))
	  (url (shr-expand-url (or url (shr--preferred-image dom)))))
      (let ((start (point-marker)))
	(when (zerop (length alt))
	  (setq alt "*"))
	(cond
         ((null url)
          ;; After further expansion, there turned out to be no valid
          ;; src in the img after all.
          )
	 ((or (member (dom-attr dom 'height) '("0" "1"))
	      (member (dom-attr dom 'width) '("0" "1")))
	  ;; Ignore zero-sized or single-pixel images.
	  )
	 ((and (not shr-inhibit-images)
	       (string-match "\\`data:" url))
	  (let ((image (shr-image-from-data (substring url (match-end 0)))))
	    (if image
		(funcall shr-put-image-function image alt
                         (list :width width :height height))
	      (insert alt))))
	 ((and (not shr-inhibit-images)
	       (string-match "\\`cid:" url))
	  (let ((url (substring url (match-end 0)))
		image)
	    (if (or (not shr-content-function)
		    (not (setq image (funcall shr-content-function url))))
		(insert alt)
	      (funcall shr-put-image-function image alt
                       (list :width width :height height)))))
	 ((or shr-inhibit-images
	      (and shr-blocked-images
		   (string-match shr-blocked-images url)))
	  (setq shr-start (point))
          (shr-insert alt))
	 ((and (not shr-ignore-cache)
	       (url-is-cached (shr-encode-url url)))
	  (funcall shr-put-image-function (shr-get-image-data url) alt
                   (list :width width :height height)))
	 (t
	  (when (and shr-ignore-cache
		     (url-is-cached (shr-encode-url url)))
	    (let ((file (url-cache-create-filename (shr-encode-url url))))
	      (when (file-exists-p file)
		(delete-file file))))
          (when (image-type-available-p 'svg)
            (insert-image
             (shr-make-placeholder-image dom)
             (or alt "")))
          (insert " ")
	  (url-queue-retrieve
           (shr-encode-url url) #'shr-image-fetched
	   (list (current-buffer) start (set-marker (make-marker) (point))
                 (list :width width :height height))
	   t
           (not (shr--use-cookies-p url shr-base)))))
	(when (zerop shr-table-depth) ;; We are not in a table.
	  (put-text-property start (point) 'keymap shr-image-map)
	  (put-text-property start (point) 'shr-alt alt)
	  (put-text-property start (point) 'image-url url)
	  (put-text-property start (point) 'image-displayer
			     (shr-image-displayer shr-content-function))
	  (put-text-property start (point) 'help-echo
			     (shr-fill-text
			      (or (dom-attr dom 'title) alt))))))))

(setq shr-put-image-function 'shr-put-image2)
