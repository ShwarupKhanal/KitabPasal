from flask import Flask, render_template,request,session,redirect,url_for,send_file
import psycopg2
import requests
import json
import os
from werkzeug.utils import secure_filename



app=Flask(__name__)
app.secret_key = 'skey'

app.config['UPLOAD_FOLDER'] = 'uploads/'
app.config['ALLOWED_EXTENSIONS'] = {'pdf'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

conn = psycopg2.connect('postgresql://postgres:1234@localhost/BookStore')

@app.route('/products/<int:product_id>')
def product_detail(product_id):
    cur = conn.cursor()

    try:
        # Fetch the current product details
        cur.execute('SELECT * FROM products WHERE id = %s', (product_id,))
        product = cur.fetchone()
        
        if not product:
            return "Product not found", 404

        # Fetch similar products based on the same category, excluding the current product
        cur.execute('SELECT * FROM products WHERE category = %s AND id != %s', (product[5], product_id))
        similar_products = cur.fetchall()

        # Fetch reviews for the current product
        cur.execute('SELECT * FROM reviews WHERE product_id = %s ORDER BY review_date DESC', (product_id,))
        reviews = cur.fetchall()

        # Check if the current product is in the user's library
        in_library = False
        if 'user' in session:
            user_id = session['user']
            cur.execute('SELECT 1 FROM library WHERE user_id = %s AND product_id = %s', (user_id, product_id))
            if cur.fetchone():
                in_library = True

        return render_template('pages/product_detail.html', product=product, similar_products=similar_products, reviews=reviews, in_library=in_library)
    
    except psycopg2.Error as e:
        # Rollback the transaction in case of an error
        conn.rollback()
        print(f"Database error: {e}")
        return "An error occurred while fetching product details.", 500
    
    finally:
        cur.close()


@app.route('/addproduct', methods=['GET', 'POST'])
def add_product():
    if 'user' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        product_name = request.form['product-name']
        product_description = request.form['product-description']
        product_price = request.form['product-price']
        product_category = request.form['product-category']
        product_image = request.form['product-image']
        
        # Handle PDF upload
        if 'product-pdf' not in request.files:
            return "No PDF file part", 400

        pdf_file = request.files['product-pdf']
        
        if pdf_file.filename == '':
            return "No selected file", 400
        
        if pdf_file and allowed_file(pdf_file.filename):
            filename = secure_filename(pdf_file.filename)
            pdf_file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            pdf_file.save(pdf_file_path)
            pdf_url = url_for('uploaded_file', filename=filename)
        else:
            return "Invalid file format", 400

        # Save the product details into the database
        cur = conn.cursor()
        try:
            cur.execute(
                'INSERT INTO products (name, description, price, image_url, pdf_url, category) VALUES (%s, %s, %s, %s, %s, %s)',
                (product_name, product_description, product_price, product_image, pdf_url, product_category)
            )
            conn.commit()
            return redirect(url_for('products'))  # Redirect to a product list or confirmation page
        except Exception as e:
            conn.rollback()
            print(f"Error occurred while adding product: {e}")
            return "An error occurred while adding the product.", 500
        finally:
            cur.close()
    else:
        # GET request: render the form page
        return render_template('pages/addproduct.html')

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    # Serve the file from the 'uploads' directory
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(file_path):
        return send_file(file_path)
    else:
        return "File not found", 404

# Ensure the uploads directory exists
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

# Routes
@app.route('/')
def home():
    cur = conn.cursor()
    cur.execute('SELECT * FROM products LIMIT 3')
    products = cur.fetchall()
    return render_template('pages/home.html', products=products)


@app.route('/products')
def products():
    cur=conn.cursor()
    cur.execute('SELECT * FROM products')
    rows=cur.fetchall()
  
    return render_template('pages/products.html',rows=rows) 

@app.route('/about')
def about():
    return render_template('pages/about.html')

@app.route('/contacts')
def contacts():
    return render_template('pages/contacts.html')
    


@app.route('/login',methods=['GET','POST'])
def login():
    if request.method == 'GET':
        if 'user' in session:
           return render_template('pages/profile.html')
        return render_template('pages/login.html')
    elif request.method == 'POST':
        email=request.form['email']
        password=request.form['password']
        cur=conn.cursor()
        cur.execute('SELECT * FROM users WHERE email=%s',(email,))
        user=cur.fetchone()
        print(email,password)
        if user and user[3]==password:
            session['user']=user[0]
            session['email']=user[2]
            return render_template('pages/home.html')
        else:
            return "Error:"

@app.route('/logout',methods=['POST'])
def logout():
    if request.method == 'POST':
        session.pop('user')
        return redirect('/')

@app.route('/signup',methods=['GET','POST'])
def signup():
    if request.method == 'GET':
        if 'user' in session:
           return render_template('pages/profile.html')
        return render_template('pages/signup.html')
    elif request.method == 'POST':
        fname = request.form['fullname']
        email=request.form['email']
        password=request.form['password']
        cpassword=request.form['cpassword']
        cur=conn.cursor()
        if password != cpassword:
            return "Error: Passwords do not match"
            
        else:
            try:
                cur = conn.cursor()
                cur.execute(
                    'INSERT INTO users (fname, email, password) VALUES (%s, %s, %s)',
                    (fname, email, password)
                )
                conn.commit()
                return redirect('/login')
            except:
                return "Error "
    
@app.route('/search')
def search():
    query = request.args.get('query')
    cur = conn.cursor()
    search_query = f"%{query}%"  # Prepare the search term for SQL LIKE
    cur.execute("SELECT * FROM products WHERE name ILIKE %s OR description ILIKE %s", (search_query, search_query))
    results = cur.fetchall()  # Fetch all matching records
    
    # Render a template to show search results
    return render_template('pages/search_results.html', results=results, query=query)

# Submit Review
@app.route('/submit_review', methods=['POST'])
def submit_review():
    if 'user' in session:
        review_text = request.form['review']
        product_id = request.args.get('product_id')  # Get product ID from query string
        reviewer_name = session.get('email', 'Anonymous')  # Use email as reviewer name or default to 'Anonymous'
        
        cur = conn.cursor()
        try:
            cur.execute(
                "INSERT INTO reviews (product_id, reviewer_name, review_text) VALUES (%s, %s, %s)",
                (product_id, reviewer_name, review_text)
            )
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Error occurred: {e}")

        return redirect(f'/products/{product_id}')
    else:
        return redirect('/login')

# Add to cart
@app.route('/add_to_cart/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    # Initialize the cart in the session if it doesn't exist
    if 'cart' not in session:
        session['cart'] = []

    # Ensure the cart is a list
    if not isinstance(session['cart'], list):
        session['cart'] = []

    # Add the product to the cart if it's not already there
    if product_id not in session['cart']:
        session['cart'].append(product_id)
        session.modified = True  # Ensure session changes are saved

    return redirect('/cart')  # Redirect to the cart or the previous page


# Cart
@app.route('/cart')
def cart():
    if 'cart' not in session or not session['cart']:
          return render_template('pages/empty_cart.html') 
    cur = conn.cursor()
    cur.execute('SELECT * FROM products WHERE id IN %s', (tuple(session['cart']),))
    cart_items = cur.fetchall()

    return render_template('pages/cart.html', cart_items=cart_items)


@app.route('/remove_from_cart/<int:product_id>', methods=['POST'])
def remove_from_cart(product_id):
    if 'cart' in session:
        # Ensure cart is a list
        if isinstance(session['cart'], list):
            if product_id in session['cart']:
                session['cart'].remove(product_id)
                session.modified = True  # Ensure session changes are saved
    return redirect('/cart')
@app.route('/add_to_library', methods=['GET'])
def add_to_library():
    if 'user' not in session:
        return redirect(url_for('login'))

    user_id = session['user']
    cart = session.get('cart', [])
    tidx = request.args.get('tidx')  # Get the tidx parameter from the query string

    if not tidx:
        # No tidx present, redirect to homepage
        return redirect('/')

    if not cart:
        return redirect(url_for('empty_cart'))

    cur = conn.cursor()

    try:
        # Insert each book in the cart into the user's library
        for product_id in cart:
            cur.execute('INSERT INTO library (user_id, product_id) VALUES (%s, %s)', (user_id, product_id))

        # Commit the transaction
        conn.commit()

        # Clear the cart
        session['cart'] = []

        return redirect(url_for('user_library'))

    except Exception as e:
        conn.rollback()
        print(f"Error occurred while adding to library: {e}")
        return "An error occurred while adding books to your library.", 500

    finally:
        cur.close()

#checkout
@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    if 'user' not in session:
        return redirect(url_for('login'))

    cart = session.get('cart', [])
    if not cart:
        return redirect(url_for('empty_cart'))

    cur = conn.cursor()

    try:
        cart_product_ids = tuple(cart) if cart else (None,)
        cur.execute('SELECT id, name, price, image_url FROM products WHERE id IN %s', (cart_product_ids,))
        products = cur.fetchall()

        product_dict = {product[0]: {'name': product[1], 'price': product[2], 'image_url': product[3]} for product in products}

        cart_items = [{'product_id': item, 
                       'product_name': product_dict.get(item, {}).get('name', 'Unknown'),
                       'product_price': product_dict.get(item, {}).get('price', 0),
                       'product_image': product_dict.get(item, {}).get('image_url', '')} for item in cart_product_ids]

        total_price = sum(item['product_price'] for item in cart_items)

        if request.method == 'POST':
            user_id = session['user']

            # Fetch user information from the database
            cur.execute('SELECT fname, email FROM users WHERE id = %s', (user_id,))
            user_info = cur.fetchone()

            if user_info:
                user_name, user_email = user_info
            else:
                return "User information not found.", 404

            url = "https://a.khalti.com/api/v2/epayment/initiate/"

            payload = {
                "return_url": "http://127.0.0.1:3000/add_to_library/",
                "website_url": "http://127.0.0.1:3000/",
                "amount": str(total_price * 100),  # Amount in paisa (example conversion)
                "purchase_order_id": f"Order{user_id}",
                "purchase_order_name": "Book Purchase",
                "customer_info": {
                    "name": user_name,
                    "email": user_email
                   
                }
            }
            headers = {
                'Authorization': 'key 05bf95cc57244045b8df5fad06748dab',
                'Content-Type': 'application/json',
            }

            response = requests.post(url, headers=headers, json=payload)

            if response.status_code == 200:
                response_data = response.json()  # Parse the JSON response
                pidx = response_data.get('pidx')
                payment_url = response_data.get('payment_url')
                expires_at = response_data.get('expires_at')
                expires_in = response_data.get('expires_in')

                # Redirect user to the payment URL
                return redirect(payment_url)
            else:
                return f"Payment initiation failed: {response.text}", 500

        return render_template('pages/checkout.html', cart_items=cart_items, total_price=total_price)

    except Exception as e:
        print(f"Error occurred while fetching products: {e}")
        return "An error occurred while fetching product details.", 500

    finally:
        cur.close()


# Liabrary
@app.route('/library')
def user_library():
    if 'user' not in session:
        return redirect(url_for('login'))

    user_id = session['user']
    cur = conn.cursor()

    try:
        # Fetch all product IDs from the user's library
        cur.execute('SELECT product_id FROM library WHERE user_id = %s', (user_id,))
        product_ids = cur.fetchall()

        # If the user has no books in their library
        if not product_ids:
            return render_template('pages/empty_library.html')

        # Extract the IDs and fetch the corresponding product details
        product_ids = [pid[0] for pid in product_ids]
        cur.execute('SELECT id, name, description, price, image_url, pdf_url FROM products WHERE id IN %s', (tuple(product_ids),))
        books = cur.fetchall()

        return render_template('pages/user_library.html', books=books)

    except Exception as e:
        print(f"Error occurred: {e}")
        return "An error occurred while fetching your library.", 500

    finally:
        cur.close()



if __name__ == '__main__':
    app.run(port=3000,debug=True)